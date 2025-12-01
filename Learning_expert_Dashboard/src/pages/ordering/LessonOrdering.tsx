import React from 'react';
import { DraggableList } from '../../components/ordering/DraggableList';

export function LessonOrdering() {
    return (
        <DraggableList
            resource="lessons"
            title="Reorder Lessons"
        />
    );
}
