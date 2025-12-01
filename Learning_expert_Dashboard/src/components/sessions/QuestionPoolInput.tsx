import React from 'react';
import { useInput, useRecordContext } from 'react-admin';
import { useWatch } from 'react-hook-form';
import { QuestionPoolSelector, PoolSelectionCriteria } from './QuestionPoolSelector';

interface QuestionPoolInputProps {
    source: string;
}

export const QuestionPoolInput: React.FC<QuestionPoolInputProps> = ({ source }) => {
    const {
        field: { value, onChange },
    } = useInput({ source });

    // Watch the number_of_questions field to pass to the selector
    const numberOfQuestions = useWatch({ name: 'number_of_questions' });

    // Also try to get it from record if not in form state yet (e.g. on load)
    const record = useRecordContext();
    const requiredQuestions = numberOfQuestions || (record && record.number_of_questions) || 10;

    return (
        <QuestionPoolSelector
            value={value as PoolSelectionCriteria}
            onChange={onChange}
            requiredQuestions={requiredQuestions}
        />
    );
};
