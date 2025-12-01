import React, { useState } from 'react';
import { DraggableList } from '../../components/ordering/DraggableList';
import { SelectInput, ReferenceInput, SimpleForm } from 'react-admin';
import { Box, Card, CardContent, Typography } from '@mui/material';

export function SessionOrdering() {
    const [selectedLessonId, setSelectedLessonId] = useState<number | null>(null);

    return (
        <Box sx={{ p: 3 }}>
            <Card sx={{ mb: 3 }}>
                <CardContent>
                    <Typography variant="h6" gutterBottom>
                        Select a Lesson
                    </Typography>
                    <Typography variant="body2" color="textSecondary" sx={{ mb: 2 }}>
                        Choose a lesson to reorder its sessions
                    </Typography>
                    <SimpleForm toolbar={false}>
                        <ReferenceInput source="lesson_id" reference="lessons">
                            <SelectInput
                                optionText="name"
                                onChange={(e: any) => setSelectedLessonId(e.target.value)}
                                fullWidth
                                label="Lesson"
                            />
                        </ReferenceInput>
                    </SimpleForm>
                </CardContent>
            </Card>

            {selectedLessonId && (
                <DraggableList
                    resource="sessions"
                    title="Reorder Sessions"
                    parentFilterField="lesson_id"
                    parentFilterValue={selectedLessonId}
                />
            )}
        </Box>
    );
}
