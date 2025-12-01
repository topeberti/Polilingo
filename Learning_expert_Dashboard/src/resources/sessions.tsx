import {
    List,
    Datagrid,
    TextField,
    Edit,
    Create,
    SimpleForm,
    TextInput,
    SelectInput,
    NumberInput,
    ReferenceInput,
    ReferenceField,
    required,
    useDataProvider,
    useNotify,
    useRedirect,
    useRecordContext,
    Filter,
    TopToolbar,
    CreateButton,
    ExportButton,
} from 'react-admin';
import { Button } from '@mui/material';
import { Link } from 'react-router-dom';
import { QuestionPoolInput } from '../components/sessions/QuestionPoolInput';
import { PoolSelectionCriteria } from '../components/sessions/QuestionPoolSelector';
import React, { useEffect } from 'react';
import { useFormContext } from 'react-hook-form';
import SortIcon from '@mui/icons-material/Sort';

/**
 * Transform form data to database structure
 * Maps pool_selection_criteria to individual columns and removes unwanted _selection fields
 */
const transformSessionData = (data: any) => {
    const {
        pool_selection_criteria,
        // Explicitly remove _selection fields that shouldn't be in the database
        concept_selection,
        heading_selection,
        topic_selection,
        block_selection,
        __temp__,
        ...rest
    } = data;

    // Extract the selection criteria
    const criteria = pool_selection_criteria as PoolSelectionCriteria | undefined;

    return {
        ...rest,
        // Map to individual database columns
        concept_id: criteria?.concept_id || null,
        heading_id: criteria?.heading_id || null,
        topic_id: criteria?.topic_id || null,
        block_id: criteria?.block_id || null,
        // Map difficulty range to separate min/max columns
        min_difficulty: criteria?.min_difficulty || null,
        max_difficulty: criteria?.max_difficulty || null,
    };
};

const SessionFilter = (props: any) => (
    <Filter {...props}>
        <TextInput source="name" label="Search" alwaysOn />
        <ReferenceInput source="lesson_id" reference="lessons" alwaysOn>
            <SelectInput optionText="name" />
        </ReferenceInput>
        <SelectInput
            source="question_selection_strategy"
            label="Strategy"
            choices={[
                { id: 'random', name: 'Random' },
                { id: 'weighted_by_difficulty', name: 'Weighted by Difficulty' },
                { id: 'adaptive', name: 'Adaptive' },
                { id: 'spaced_repetition', name: 'Spaced Repetition' },
            ]}
        />
    </Filter>
);

const SessionListActions = () => (
    <TopToolbar>
        <Button
            component={Link}
            to="/sessions/order"
            startIcon={<SortIcon />}
        >
            Reorder
        </Button>
        <CreateButton />
        <ExportButton />
    </TopToolbar>
);

export const SessionList = () => (
    <List filters={<SessionFilter />} actions={<SessionListActions />}>
        <Datagrid rowClick="edit">
            <TextField source="id" />
            <TextField source="name" />
            <ReferenceField source="lesson_id" reference="lessons" />
            <TextField source="number_of_questions" label="# Questions" />
            <TextField source="order" label="Order" />
            <TextField source="question_selection_strategy" label="Strategy" />
        </Datagrid>
    </List>
);

const usePopulatePool = () => {
    const dataProvider = useDataProvider();
    const notify = useNotify();
    const redirect = useRedirect();

    return async (record: any) => {
        // Reconstruct pool_selection_criteria from database columns
        const criteria: PoolSelectionCriteria = {
            concept_id: record.concept_id || null,
            heading_id: record.heading_id || null,
            topic_id: record.topic_id || null,
            block_id: record.block_id || null,
            min_difficulty: record.min_difficulty || null,
            max_difficulty: record.max_difficulty || null,
        };

        // If no question pool criteria, just show success and redirect
        if (!criteria.concept_id && !criteria.heading_id && !criteria.topic_id && !criteria.block_id) {
            notify('Session saved successfully', { type: 'success' });
            redirect('list', 'sessions');
            return;
        }

        // If there is question pool criteria, populate the pool
        try {
            // @ts-ignore - custom method
            const { data: count } = await dataProvider.populateSessionQuestionPool({
                sessionId: record.id,
                blockId: criteria.block_id,
                topicId: criteria.topic_id,
                headingId: criteria.heading_id,
                conceptId: criteria.concept_id,
                minDifficulty: criteria.min_difficulty,
                maxDifficulty: criteria.max_difficulty,
            });

            notify(`Session saved successfully! ${count} questions added to pool`, { type: 'success' });
            redirect('list', 'sessions');
        } catch (error: any) {
            console.error('Error populating pool:', error);
            notify(`Session saved but failed to populate pool: ${error.message}`, { type: 'warning' });
            redirect('list', 'sessions');
        }
    };
};

// Custom form wrapper to populate pool_selection_criteria from DB columns when editing
const InitializeEditForm = () => {
    const record = useRecordContext();
    const { reset, getValues } = useFormContext();
    const [initialized, setInitialized] = React.useState(false);

    useEffect(() => {
        // Only initialize once when record is loaded and not already initialized
        if (record && record.id && !initialized) {
            const currentValues = getValues();

            // Check if pool_selection_criteria is already set (to avoid overwriting user changes)
            if (!currentValues.pool_selection_criteria) {
                // Build pool_selection_criteria from database columns
                const pool_selection_criteria = {
                    concept_id: record.concept_id || null,
                    heading_id: record.heading_id || null,
                    topic_id: record.topic_id || null,
                    block_id: record.block_id || null,
                    min_difficulty: record.min_difficulty || null,
                    max_difficulty: record.max_difficulty || null,
                };

                // Update the form with the transformed data
                reset({
                    ...record,
                    pool_selection_criteria,
                });

                setInitialized(true);
            }
        }
    }, [record, reset, getValues, initialized]);

    return null;
};

export const SessionEdit = () => {
    const populatePool = usePopulatePool();

    return (
        <Edit
            mutationMode="pessimistic"
            mutationOptions={{ onSuccess: populatePool }}
            transform={transformSessionData}
        >
            <SimpleForm>
                <InitializeEditForm />
                <TextInput source="name" validate={[required()]} fullWidth />
                <ReferenceInput source="lesson_id" reference="lessons">
                    <SelectInput optionText="name" validate={[required()]} fullWidth />
                </ReferenceInput>
                <NumberInput source="number_of_questions" label="Number of Questions" validate={[required()]} />
                <NumberInput source="order" label="Order/Position" validate={[required()]} />
                <SelectInput
                    source="question_selection_strategy"
                    choices={[
                        { id: 'random', name: 'Random' },
                        { id: 'weighted_by_difficulty', name: 'Weighted by Difficulty' },
                        { id: 'adaptive', name: 'Adaptive' },
                        { id: 'spaced_repetition', name: 'Spaced Repetition' },
                    ]}
                    validate={[required()]}
                />

                <QuestionPoolInput source="pool_selection_criteria" />
            </SimpleForm>
        </Edit>
    );
};

export const SessionCreate = () => {
    const populatePool = usePopulatePool();

    return (
        <Create
            mutationOptions={{ onSuccess: populatePool }}
            transform={transformSessionData}
        >
            <SimpleForm>
                <TextInput source="name" validate={[required()]} fullWidth />
                <ReferenceInput source="lesson_id" reference="lessons">
                    <SelectInput optionText="name" validate={[required()]} fullWidth />
                </ReferenceInput>
                <NumberInput source="number_of_questions" label="Number of Questions" defaultValue={10} validate={[required()]} />
                <NumberInput source="order" label="Order/Position" defaultValue={1} validate={[required()]} />
                <SelectInput
                    source="question_selection_strategy"
                    choices={[
                        { id: 'random', name: 'Random' },
                        { id: 'weighted_by_difficulty', name: 'Weighted by Difficulty' },
                        { id: 'adaptive', name: 'Adaptive' },
                        { id: 'spaced_repetition', name: 'Spaced Repetition' },
                    ]}
                    defaultValue="random"
                    validate={[required()]}
                />

                <QuestionPoolInput source="pool_selection_criteria" />
            </SimpleForm>
        </Create>
    );
};
