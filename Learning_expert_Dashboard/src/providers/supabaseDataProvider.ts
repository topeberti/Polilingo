import { DataProvider, GetListParams, GetOneParams, CreateParams, UpdateParams, DeleteParams } from 'react-admin';
import { supabase } from '../authProvider';

export const dataProvider: DataProvider = {
    getList: async (resource: string, params: GetListParams) => {
        const { page, perPage } = params.pagination;
        const { field, order } = params.sort;
        const start = (page - 1) * perPage;
        const end = start + perPage - 1;

        // Special handling for app_configuration: fetch from both tables
        if (resource === 'app_configuration') {
            // Fetch from both tables
            const [appConfigResult, learningConfigResult] = await Promise.all([
                supabase.from('app_configuration').select('*'),
                supabase.from('learning_path_config').select('*'),
            ]);

            if (appConfigResult.error) throw new Error(appConfigResult.error.message);
            if (learningConfigResult.error) throw new Error(learningConfigResult.error.message);

            // Combine data from both tables and add source_table field
            let combinedData = [
                ...(appConfigResult.data || []).map((item: any) => ({ ...item, source_table: 'app_configuration' })),
                ...(learningConfigResult.data || []).map((item: any) => ({ ...item, source_table: 'learning_path_config' })),
            ];

            // Apply filters
            if (params.filter) {
                Object.keys(params.filter).forEach((key) => {
                    if (key === 'q') {
                        const searchTerm = params.filter.q.toLowerCase();
                        combinedData = combinedData.filter((item: any) =>
                            item.config_key?.toLowerCase().includes(searchTerm) ||
                            item.description?.toLowerCase().includes(searchTerm)
                        );
                    } else if (key !== 'source_table') {
                        combinedData = combinedData.filter((item: any) => item[key] === params.filter[key]);
                    }
                });
            }

            // Apply sorting
            combinedData.sort((a: any, b: any) => {
                const aValue = a[field];
                const bValue = b[field];
                if (aValue < bValue) return order === 'ASC' ? -1 : 1;
                if (aValue > bValue) return order === 'ASC' ? 1 : -1;
                return 0;
            });

            const total = combinedData.length;

            // Apply pagination
            const paginatedData = combinedData.slice(start, end + 1);

            // Map config_key to id for React Admin
            const resultData = paginatedData.map((item: any) => ({
                ...item,
                id: item.config_key,
            }));

            return {
                data: resultData,
                total,
            };
        }

        // Standard handling for other resources
        let query = supabase.from(resource).select('*', { count: 'exact' });

        // Apply filters
        if (params.filter) {
            Object.keys(params.filter).forEach((key) => {
                if (key === 'q') {
                    // Text search
                    query = query.or(`text.ilike.%${params.filter.q}%,name.ilike.%${params.filter.q}%`);
                } else if (key === 'name' || key === 'text' || key === 'description') {
                    // Use pattern matching for text fields
                    query = query.ilike(key, `%${params.filter[key]}%`);
                } else {
                    query = query.eq(key, params.filter[key]);
                }
            });
        }

        // Apply sorting
        query = query.order(field, { ascending: order === 'ASC' });

        // Apply pagination
        query = query.range(start, end);

        const { data, error, count } = await query;

        if (error) throw new Error(error.message);

        return {
            data: data || [],
            total: count || 0,
        };
    },

    getOne: async (resource: string, params: GetOneParams) => {
        if (resource === 'app_configuration') {
            // Try both tables
            const [appResult, learningResult] = await Promise.all([
                supabase.from('app_configuration').select('*').eq('config_key', params.id).single(),
                supabase.from('learning_path_config').select('*').eq('config_key', params.id).single(),
            ]);

            // Use whichever succeeded
            if (!appResult.error && appResult.data) {
                return { data: { ...appResult.data, id: appResult.data.config_key, source_table: 'app_configuration' } };
            }
            if (!learningResult.error && learningResult.data) {
                return { data: { ...learningResult.data, id: learningResult.data.config_key, source_table: 'learning_path_config' } };
            }

            throw new Error(`Configuration with key ${params.id} not found in either table`);
        }

        const { data, error } = await supabase
            .from(resource)
            .select('*')
            .eq('id', params.id)
            .single();

        if (error) {
            throw new Error(`Failed to get ${resource}: ${error.message}`);
        }

        if (!data) {
            throw new Error(
                `${resource} with id ${params.id} not found. This might be due to Row Level Security (RLS) policies. ` +
                `Please ensure you have SELECT permissions on the ${resource} table.`
            );
        }

        return { data };
    },

    getMany: async (resource: string, params: { ids: any[] }) => {
        const idField = resource === 'app_configuration' ? 'config_key' : 'id';
        const { data, error } = await supabase
            .from(resource)
            .select('*')
            .in(idField, params.ids);

        if (error) throw new Error(error.message);

        const resultData = resource === 'app_configuration'
            ? (data || []).map((item: any) => ({ ...item, id: item.config_key }))
            : (data || []);

        return { data: resultData };
    },

    getManyReference: async (resource: string, params: any) => {
        const { page, perPage } = params.pagination;
        const { field, order } = params.sort;
        const start = (page - 1) * perPage;
        const end = start + perPage - 1;

        // @ts-ignore
        let query = supabase
            .from(resource)
            .select('*', { count: 'exact' })
            .eq(params.target, params.id);

        query = query.order(field, { ascending: order === 'ASC' });
        query = query.range(start, end);

        const { data, error, count } = await query;

        if (error) throw new Error(error.message);

        const resultData = resource === 'app_configuration'
            ? (data || []).map((item: any) => ({ ...item, id: item.config_key }))
            : (data || []);

        return {
            data: resultData,
            total: count || 0,
        };
    },

    create: async (resource: string, params: CreateParams) => {
        if (resource === 'app_configuration') {
            const targetTable = params.data.source_table || 'app_configuration';
            const { source_table, ...dataToInsert } = params.data;

            const { data, error } = await supabase
                .from(targetTable)
                .insert(dataToInsert)
                .select()
                .single();

            if (error) {
                throw new Error(`Failed to create in ${targetTable}: ${error.message}`);
            }

            return { data: { ...data, id: data.config_key, source_table: targetTable } };
        }

        const { data, error } = await supabase
            .from(resource)
            .insert(params.data)
            .select()
            .single();

        if (error) {
            throw new Error(`Failed to create ${resource}: ${error.message}`);
        }

        if (!data) {
            throw new Error(
                `Failed to create ${resource}. This might be due to Row Level Security (RLS) policies. ` +
                `Please ensure you have INSERT permissions on the ${resource} table.`
            );
        }

        return { data };
    },

    update: async (resource: string, params: UpdateParams) => {
        if (resource === 'app_configuration') {
            const targetTable = params.data.source_table || params.previousData?.source_table || 'app_configuration';
            const { source_table, id, ...dataToUpdate } = params.data;

            const { data, error } = await supabase
                .from(targetTable)
                .update(dataToUpdate)
                .eq('config_key', params.id)
                .select()
                .single();

            if (error) {
                throw new Error(`Failed to update in ${targetTable}: ${error.message}`);
            }

            return { data: { ...data, id: data.config_key, source_table: targetTable } };
        }

        const { data, error } = await supabase
            .from(resource)
            .update(params.data)
            .eq('id', params.id)
            .select()
            .single();

        if (error) {
            throw new Error(`Failed to update ${resource}: ${error.message}`);
        }

        if (!data) {
            throw new Error(
                `Failed to update ${resource} with id ${params.id}. This might be due to Row Level Security (RLS) policies. ` +
                `Please ensure you have UPDATE permissions on the ${resource} table.`
            );
        }

        return { data };
    },

    updateMany: async (resource: string, params: { ids: any[]; data: any }) => {
        const idField = resource === 'app_configuration' ? 'config_key' : 'id';
        const { error } = await supabase
            .from(resource)
            .update(params.data)
            .in(idField, params.ids);

        if (error) throw new Error(error.message);

        return { data: params.ids };
    },

    delete: async (resource: string, params: DeleteParams) => {
        if (resource === 'app_configuration') {
            const targetTable = params.previousData?.source_table || 'app_configuration';

            const { data, error } = await supabase
                .from(targetTable)
                .delete()
                .eq('config_key', params.id)
                .select()
                .single();

            if (error) {
                throw new Error(`Failed to delete from ${targetTable}: ${error.message}`);
            }

            return { data: { ...data, id: data.config_key, source_table: targetTable } };
        }

        const { data, error } = await supabase
            .from(resource)
            .delete()
            .eq('id', params.id)
            .select()
            .single();

        if (error) {
            throw new Error(`Failed to delete ${resource}: ${error.message}`);
        }

        if (!data) {
            throw new Error(
                `Failed to delete ${resource} with id ${params.id}. This might be due to Row Level Security (RLS) policies. ` +
                `Please ensure you have DELETE permissions on the ${resource} table.`
            );
        }

        return { data };
    },

    deleteMany: async (resource: string, params: { ids: any[] }) => {
        const idField = resource === 'app_configuration' ? 'config_key' : 'id';
        const { error } = await supabase
            .from(resource)
            .delete()
            .in(idField, params.ids);

        if (error) throw new Error(error.message);

        return { data: params.ids };
    },


    // Custom method for question preview
    getQuestionCountByCriteria: async (params: {
        blockId?: string;
        topicId?: string;
        headingId?: string;
        conceptId?: string;
        minDifficulty?: number;
        maxDifficulty?: number;
    }) => {
        const { data, error } = await supabase.rpc('get_question_count_by_criteria', {
            p_block_id: params.blockId || null,
            p_topic_id: params.topicId || null,
            p_heading_id: params.headingId || null,
            p_concept_id: params.conceptId || null,
            p_min_difficulty: params.minDifficulty || null,
            p_max_difficulty: params.maxDifficulty || null,
        });

        if (error) throw new Error(`Failed to get question count: ${error.message}`);
        return { data };
    },

    // Custom method for batch updating order values
    batchUpdateOrder: async (resource: string, params: { data: Array<{ id: number; order: number }> }) => {
        try {
            // Update each item's order individually using Promise.all for better performance
            const updates = params.data.map((item) =>
                supabase
                    .from(resource)
                    .update({ order: item.order })
                    .eq('id', item.id)
            );

            const results = await Promise.all(updates);

            // Check for errors in any of the updates
            const firstError = results.find((result) => result.error);
            if (firstError && firstError.error) {
                throw new Error(`Failed to update order: ${firstError.error.message}`);
            }

            return { data: params.data.length };
        } catch (error: any) {
            throw new Error(`Failed to update order: ${error.message}`);
        }
    },
};
