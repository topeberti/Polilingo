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
    BooleanInput,
    required,
} from 'react-admin';
import { QUESTION_SELECTION_STRATEGIES } from '../constants/algorithms';

export const ChallengeTemplateList = () => (
    <List>
        <Datagrid rowClick="edit">
            <TextField source="id" />
            <TextField source="name" label="Name" />
            <TextField source="challenge_type" label="Type" />
            <TextField source="time_limit" label="Time Limit (s)" />
            <TextField source="number_of_questions" label="# Questions" />
            <TextField source="xp_multiplier" label="XP Multiplier" />
        </Datagrid>
    </List>
);

export const ChallengeTemplateEdit = () => (
    <Edit>
        <SimpleForm>
            <TextInput source="name" label="Name" validate={[required()]} fullWidth />
            <SelectInput
                source="challenge_type"
                choices={[
                    { id: 'lightning_round', name: 'Lightning Round' },
                    { id: 'review_weak_topics', name: 'Review Weak Topics' },
                    { id: 'review_mistakes', name: 'Review Mistakes' },
                    { id: 'speed_run', name: 'Speed Run' },
                    { id: 'accuracy_challenge', name: 'Accuracy Challenge' },
                    { id: 'spaced_repetition_review', name: 'Spaced Repetition Review' },
                ]}
                validate={[required()]}
            />
            <TextInput source="description" multiline rows={3} fullWidth />
            <TextInput source="icon_url" label="Icon URL" fullWidth />
            <NumberInput source="time_limit" label="Time Limit (seconds)" />
            <NumberInput source="number_of_questions" label="Number of Questions" validate={[required()]} />
            <SelectInput
                source="question_selection_algorithm"
                choices={QUESTION_SELECTION_STRATEGIES}
                validate={[required()]}
            />
            <SelectInput
                source="scoring_formula"
                choices={[
                    { id: 'standard', name: 'Standard' },
                    { id: 'time_bonus', name: 'Time Bonus' },
                    { id: 'combo_multiplier', name: 'Combo Multiplier' },
                    { id: 'no_penalty', name: 'No Penalty' },
                ]}
                validate={[required()]}
            />
            <NumberInput source="xp_multiplier" label="XP Multiplier" step={0.1} validate={[required()]} />
            <NumberInput source="cooldown_period" label="Cooldown Period (hours)" />
            <BooleanInput source="active" label="Active" />
        </SimpleForm>
    </Edit>
);

export const ChallengeTemplateCreate = () => (
    <Create>
        <SimpleForm>
            <TextInput source="name" label="Name" validate={[required()]} fullWidth />
            <SelectInput
                source="challenge_type"
                choices={[
                    { id: 'lightning_round', name: 'Lightning Round' },
                    { id: 'review_weak_topics', name: 'Review Weak Topics' },
                    { id: 'review_mistakes', name: 'Review Mistakes' },
                    { id: 'speed_run', name: 'Speed Run' },
                    { id: 'accuracy_challenge', name: 'Accuracy Challenge' },
                    { id: 'spaced_repetition_review', name: 'Spaced Repetition Review' },
                ]}
                validate={[required()]}
            />
            <TextInput source="description" multiline rows={3} fullWidth />
            <TextInput source="icon_url" label="Icon URL" fullWidth />
            <NumberInput source="time_limit" label="Time Limit (seconds)" defaultValue={60} />
            <NumberInput source="number_of_questions" label="Number of Questions" defaultValue={10} validate={[required()]} />
            <SelectInput
                source="question_selection_algorithm"
                choices={QUESTION_SELECTION_STRATEGIES}
                defaultValue="random"
                validate={[required()]}
            />
            <SelectInput
                source="scoring_formula"
                choices={[
                    { id: 'standard', name: 'Standard' },
                    { id: 'time_bonus', name: 'Time Bonus' },
                    { id: 'combo_multiplier', name: 'Combo Multiplier' },
                    { id: 'no_penalty', name: 'No Penalty' },
                ]}
                defaultValue="standard"
                validate={[required()]}
            />
            <NumberInput source="xp_multiplier" label="XP Multiplier" defaultValue={1.0} step={0.1} validate={[required()]} />
            <NumberInput source="cooldown_period" label="Cooldown Period (hours)" defaultValue={24} />
            <BooleanInput source="active" label="Active" defaultValue={true} />
        </SimpleForm>
    </Create>
);
