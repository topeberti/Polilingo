import React, { useState } from 'react';
import { DraggableList } from '../../components/ordering/DraggableList';
import { SelectInput, ReferenceInput, SimpleForm } from 'react-admin';
import { Box, Card, CardContent, Typography } from '@mui/material';

export function TopicOrdering() {
    const [selectedBlockId, setSelectedBlockId] = useState<number | null>(null);

    return (
        <Box sx={{ p: 3 }}>
            <Card sx={{ mb: 3 }}>
                <CardContent>
                    <Typography variant="h6" gutterBottom>
                        Select a Block
                    </Typography>
                    <Typography variant="body2" color="textSecondary" sx={{ mb: 2 }}>
                        Choose a block to reorder its topics
                    </Typography>
                    <SimpleForm toolbar={false}>
                        <ReferenceInput source="block_id" reference="blocks">
                            <SelectInput
                                optionText="name"
                                onChange={(e: any) => setSelectedBlockId(e.target.value)}
                                fullWidth
                                label="Block"
                            />
                        </ReferenceInput>
                    </SimpleForm>
                </CardContent>
            </Card>

            {selectedBlockId && (
                <DraggableList
                    resource="topics"
                    title="Reorder Topics"
                    parentFilterField="block_id"
                    parentFilterValue={selectedBlockId}
                />
            )}
        </Box>
    );
}
