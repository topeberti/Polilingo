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
    required,
    Filter,
    TopToolbar,
    CreateButton,
    ExportButton,
} from 'react-admin';
import { Button } from '@mui/material';
import { Link } from 'react-router-dom';
import SortIcon from '@mui/icons-material/Sort';

const BlockFilter = (props: any) => (
    <Filter {...props}>
        <TextInput source="name" label="Search" alwaysOn />
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

const BlockListActions = () => (
    <TopToolbar>
        <Button
            component={Link}
            to="/blocks/order"
            startIcon={<SortIcon />}
        >
            Reorder
        </Button>
        <CreateButton />
        <ExportButton />
    </TopToolbar>
);

export const BlockList = () => (
    <List filters={<BlockFilter />} actions={<BlockListActions />}>
        <Datagrid rowClick="edit">
            <TextField source="id" />
            <TextField source="name" />
            <TextField source="description" />
            <TextField source="order" label="Order" />
            <TextField source="status" />
        </Datagrid>
    </List>
);

export const BlockEdit = () => (
    <Edit>
        <SimpleForm>
            <TextInput source="name" validate={[required()]} fullWidth />
            <TextInput source="description" multiline rows={3} fullWidth />
            <NumberInput source="order" label="Order" validate={[required()]} />
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

export const BlockCreate = () => (
    <Create>
        <SimpleForm>
            <TextInput source="name" validate={[required()]} fullWidth />
            <TextInput source="description" multiline rows={3} fullWidth />
            <NumberInput source="order" label="Order" defaultValue={1} validate={[required()]} />
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
