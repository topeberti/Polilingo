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
    RadioButtonGroupInput,
    required,
    Filter,
    SearchInput,
} from 'react-admin';

const QuestionFilter = (props: any) => (
    <Filter {...props}>
        <SearchInput source="q" alwaysOn />
        <ReferenceInput source="concept_id" reference="concepts" alwaysOn>
            <SelectInput optionText="name" />
        </ReferenceInput>
        <NumberInput source="difficulty" />
        <SelectInput
            source="status"
            choices={[
                { id: 'active', name: 'Active' },
                { id: 'draft', name: 'Draft' },
            ]}
        />
    </Filter>
);

export const QuestionList = () => (
    <List filters={<QuestionFilter />}>
        <Datagrid rowClick="edit">
            <TextField source="id" />
            <TextField source="text" label="Question Text" />
            <ReferenceField source="concept_id" reference="concepts" />
            <TextField source="difficulty" />
            <TextField source="correct_option" label="Answer" />
            <TextField source="status" />
        </Datagrid>
    </List>
);

export const QuestionEdit = () => (
    <Edit>
        <SimpleForm>
            <TextInput source="text" label="Question Text" validate={[required()]} fullWidth multiline rows={3} />

            <TextInput source="option_a" label="Option A" validate={[required()]} fullWidth />
            <TextInput source="option_b" label="Option B" validate={[required()]} fullWidth />
            <TextInput source="option_c" label="Option C" validate={[required()]} fullWidth />

            <RadioButtonGroupInput
                source="correct_option"
                choices={[
                    { id: 'a', name: 'A' },
                    { id: 'b', name: 'B' },
                    { id: 'c', name: 'C' },
                ]}
                validate={[required()]}
            />

            <TextInput source="explanation" validate={[required()]} fullWidth multiline rows={3} />

            <ReferenceInput source="concept_id" reference="concepts">
                <SelectInput optionText="name" validate={[required()]} fullWidth />
            </ReferenceInput>

            <NumberInput source="difficulty" min={1} max={10} validate={[required()]} />
            <TextInput source="source" fullWidth />

            <SelectInput
                source="status"
                choices={[
                    { id: 'active', name: 'Active' },
                    { id: 'draft', name: 'Draft' },
                ]}
                validate={[required()]}
            />
        </SimpleForm>
    </Edit>
);

export const QuestionCreate = () => (
    <Create>
        <SimpleForm>
            <TextInput source="text" label="Question Text" validate={[required()]} fullWidth multiline rows={3} />

            <TextInput source="option_a" label="Option A" validate={[required()]} fullWidth />
            <TextInput source="option_b" label="Option B" validate={[required()]} fullWidth />
            <TextInput source="option_c" label="Option C" validate={[required()]} fullWidth />

            <RadioButtonGroupInput
                source="correct_option"
                choices={[
                    { id: 'a', name: 'A' },
                    { id: 'b', name: 'B' },
                    { id: 'c', name: 'C' },
                ]}
                validate={[required()]}
            />

            <TextInput source="explanation" validate={[required()]} fullWidth multiline rows={3} />

            <ReferenceInput source="concept_id" reference="concepts">
                <SelectInput optionText="name" validate={[required()]} fullWidth />
            </ReferenceInput>

            <NumberInput source="difficulty" min={1} max={10} defaultValue={5} validate={[required()]} />
            <TextInput source="source" fullWidth />

            <SelectInput
                source="status"
                choices={[
                    { id: 'active', name: 'Active' },
                    { id: 'draft', name: 'Draft' },
                ]}
                defaultValue="draft"
                validate={[required()]}
            />
        </SimpleForm>
    </Create>
);
