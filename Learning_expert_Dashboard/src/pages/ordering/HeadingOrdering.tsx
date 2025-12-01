import React, { useState } from 'react';
import { DraggableList } from '../../components/ordering/DraggableList';
import { SelectInput, ReferenceInput, SimpleForm } from 'react-admin';
import { Box, Card, CardContent, Typography } from '@mui/material';

export function HeadingOrdering() {
    const [selectedTopicId, setSelectedTopicId] = useState<number | null>(null);

    return (
        <Box sx={{ p: 3 }}>
            <Card sx={{ mb: 3 }}>
                <CardContent>
                    <Typography variant="h6" gutterBottom>
                        Select a Topic
                    </Typography>
                    <Typography variant="body2" color="textSecondary" sx={{ mb: 2 }}>
                        Choose a topic to reorder its headings
                    </Typography>
                    <SimpleForm toolbar={false}>
                        <ReferenceInput source="topic_id" reference="topics">
                            <SelectInput
                                optionText="name"
                                onChange={(e: any) => setSelectedTopicId(e.target.value)}
                                fullWidth
                                label="Topic"
                            />
                        </ReferenceInput>
                    </SimpleForm>
                </CardContent>
            </Card>

            {selectedTopicId && (
                <DraggableList
                    resource="headings"
                    title="Reorder Headings"
                    parentFilterField="topic_id"
                    parentFilterValue={selectedTopicId}
                />
            )}
        </Box>
    );
}
