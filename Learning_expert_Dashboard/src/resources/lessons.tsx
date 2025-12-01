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

const LessonFilter = (props: any) => (
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

const LessonListActions = () => (
    <TopToolbar>
        <Button
            component={Link}
            to="/lessons/order"
            startIcon={<SortIcon />}
        >
            Reorder
        </Button>
        <CreateButton />
        <ExportButton />
    </TopToolbar>
);

export const LessonList = () => (
    <List filters={<LessonFilter />} actions={<LessonListActions />}>
        <Datagrid rowClick="edit">
            <TextField source="id" />
            <TextField source="name" />
            <TextField source="order" label="Order" />
            <TextField source="xp_reward" label="XP Reward" />
            <TextField source="status" />
        </Datagrid>
    </List>
);

export const LessonEdit = () => (
    <Edit>
        <SimpleForm>
            <TextInput source="name" validate={[required()]} fullWidth />
            <NumberInput source="order" label="Order/Position" validate={[required()]} />
            <NumberInput source="xp_reward" label="XP Reward" validate={[required()]} />
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

export const LessonCreate = () => (
    <Create>
        <SimpleForm>
            <TextInput source="name" validate={[required()]} fullWidth />
            <NumberInput source="order" label="Order/Position" defaultValue={1} validate={[required()]} />
            <NumberInput source="xp_reward" label="XP Reward" defaultValue={100} validate={[required()]} />
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
