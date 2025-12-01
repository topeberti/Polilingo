import {
    List,
    Datagrid,
    TextField,
    Edit,
    Create,
    SimpleForm,
    TextInput,
    SelectInput,
    required,
    Filter,
    FunctionField,
} from 'react-admin';

const AppConfigurationFilter = (props: any) => (
    <Filter {...props}>
        <TextInput source="q" label="Search" alwaysOn />
        <SelectInput
            source="category"
            choices={[
                { id: 'gamification', name: 'Gamification' },
                { id: 'learning', name: 'Learning' },
                { id: 'social', name: 'Social' },
                { id: 'challenges', name: 'Challenges' },
                { id: 'notifications', name: 'Notifications' },
            ]}
        />
    </Filter>
);

export const AppConfigurationList = () => (
    <List filters={<AppConfigurationFilter />} sort={{ field: 'config_key', order: 'ASC' }}>
        <Datagrid rowClick="edit">
            <TextField source="config_key" label="Key" />
            <FunctionField
                label="Value"
                render={(record: any) => {
                    if (!record.config_value) return '';
                    const value = typeof record.config_value === 'object'
                        ? JSON.stringify(record.config_value)
                        : String(record.config_value);
                    return value.length > 50 ? `${value.substring(0, 50)}...` : value;
                }}
            />
            <TextField source="data_type" label="Type" />
            <TextField source="category" />
            <FunctionField
                label="Source"
                render={(record: any) => record.source_table === 'learning_path_config' ? 'Learning Path' : 'App'}
            />
        </Datagrid>
    </List>
);

export const AppConfigurationEdit = () => (
    <Edit>
        <SimpleForm>
            <TextInput source="config_key" disabled fullWidth />
            <TextInput source="source_table" disabled fullWidth label="Source Table" />
            <SelectInput
                source="data_type"
                choices={[
                    { id: 'integer', name: 'Integer' },
                    { id: 'boolean', name: 'Boolean' },
                    { id: 'string', name: 'String' },
                    { id: 'json', name: 'JSON' },
                    { id: 'array', name: 'Array' },
                ]}
                disabled
            />
            <SelectInput
                source="category"
                choices={[
                    { id: 'gamification', name: 'Gamification' },
                    { id: 'learning', name: 'Learning' },
                    { id: 'social', name: 'Social' },
                    { id: 'challenges', name: 'Challenges' },
                    { id: 'notifications', name: 'Notifications' },
                ]}
                disabled
            />
            <TextInput source="description" multiline rows={3} fullWidth />
            <TextInput source="config_value" multiline rows={5} fullWidth validate={[required()]} />
        </SimpleForm>
    </Edit>
);

export const AppConfigurationCreate = () => (
    <Create>
        <SimpleForm>
            <SelectInput
                source="source_table"
                label="Table"
                choices={[
                    { id: 'app_configuration', name: 'App Configuration' },
                    { id: 'learning_path_config', name: 'Learning Path Config' },
                ]}
                defaultValue="app_configuration"
                validate={[required()]}
                fullWidth
            />
            <TextInput source="config_key" validate={[required()]} fullWidth />
            <SelectInput
                source="data_type"
                choices={[
                    { id: 'integer', name: 'Integer' },
                    { id: 'boolean', name: 'Boolean' },
                    { id: 'string', name: 'String' },
                    { id: 'json', name: 'JSON' },
                    { id: 'array', name: 'Array' },
                ]}
                validate={[required()]}
            />
            <SelectInput
                source="category"
                choices={[
                    { id: 'gamification', name: 'Gamification' },
                    { id: 'learning', name: 'Learning' },
                    { id: 'social', name: 'Social' },
                    { id: 'challenges', name: 'Challenges' },
                    { id: 'notifications', name: 'Notifications' },
                ]}
                validate={[required()]}
            />
            <TextInput source="description" multiline rows={3} fullWidth />
            <TextInput source="config_value" multiline rows={5} fullWidth validate={[required()]} />
        </SimpleForm>
    </Create>
);
