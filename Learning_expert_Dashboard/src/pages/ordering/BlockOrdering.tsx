import React from 'react';
import { DraggableList } from '../../components/ordering/DraggableList';

export function BlockOrdering() {
    return (
        <DraggableList
            resource="blocks"
            title="Reorder Blocks"
        />
    );
}
