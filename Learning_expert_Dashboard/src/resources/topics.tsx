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
    Filter,
    TopToolbar,
    CreateButton,
    ExportButton,
} from 'react-admin';
import { Button } from '@mui/material';
import { Link } from 'react-router-dom';
import SortIcon from '@mui/icons-material/Sort';

const TopicFilter = (props: any) => (
    <Filter {...props}>
        <TextInput source="name" label="Search" alwaysOn />
        <ReferenceInput source="block_id" reference="blocks" alwaysOn>
            <SelectInput optionText="name" />
        </ReferenceInput>
        <SelectInput
            source="status"
            choices={[
                { id: 'active', name: 'Active' },
                { id: 'draft', name: 'Draft' },
                { id: 'archived', name: 'Archived' },
            ]}
        />
    </Filter>
);

const TopicListActions = () => (
    <TopToolbar>
        <Button
            component={Link}
            to="/topics/order"
            startIcon={<SortIcon />}
        >
            Reorder
        </Button>
        <CreateButton />
        <ExportButton />
    </TopToolbar>
);

export const TopicList = () => (
    <List filters={<TopicFilter />} actions={<TopicListActions />}>
        <Datagrid rowClick="edit">
            <TextField source="id" />
            <TextField source="name" />
            <ReferenceField source="block_id" reference="blocks" />
            <TextField source="order" label="Order" />
            <TextField source="status" />
        </Datagrid>
    </List>
);

export const TopicEdit = () => (
    <Edit>
        <SimpleForm>
            <TextInput source="name" validate={[required()]} fullWidth />
            <ReferenceInput source="block_id" reference="blocks">
                <SelectInput optionText="name" validate={[required()]} fullWidth />
            </ReferenceInput>
            <TextInput source="description" multiline rows={3} fullWidth />
            <NumberInput source="order" label="Order/Position" validate={[required()]} />
            <SelectInput
                source="status"
                choices={[
                    { id: 'active', name: 'Active' },
                    { id: 'draft', name: 'Draft' },
                    { id: 'archived', name: 'Archived' },
                ]}
                validate={[required()]}
            />
        </SimpleForm>
    </Edit>
);

export const TopicCreate = () => (
    <Create>
        <SimpleForm>
            <TextInput source="name" validate={[required()]} fullWidth />
            <ReferenceInput source="block_id" reference="blocks">
                <SelectInput optionText="name" validate={[required()]} fullWidth />
            </ReferenceInput>
            <TextInput source="description" multiline rows={3} fullWidth />
            <NumberInput source="order" label="Order/Position" defaultValue={1} validate={[required()]} />
            <SelectInput
                source="status"
                choices={[
                    { id: 'active', name: 'Active' },
                    { id: 'draft', name: 'Draft' },
                    { id: 'archived', name: 'Archived' },
                ]}
                defaultValue="draft"
                validate={[required()]}
            />
        </SimpleForm>
    </Create>
);
