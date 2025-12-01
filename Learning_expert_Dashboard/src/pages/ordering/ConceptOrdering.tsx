import React, { useState } from 'react';
import { DraggableList } from '../../components/ordering/DraggableList';
import { SelectInput, ReferenceInput, SimpleForm } from 'react-admin';
import { Box, Card, CardContent, Typography } from '@mui/material';

export function ConceptOrdering() {
    const [selectedHeadingId, setSelectedHeadingId] = useState<number | null>(null);

    return (
        <Box sx={{ p: 3 }}>
            <Card sx={{ mb: 3 }}>
                <CardContent>
                    <Typography variant="h6" gutterBottom>
                        Select a Heading
                    </Typography>
                    <Typography variant="body2" color="textSecondary" sx={{ mb: 2 }}>
                        Choose a heading to reorder its concepts
                    </Typography>
                    <SimpleForm toolbar={false}>
                        <ReferenceInput source="heading_id" reference="headings">
                            <SelectInput
                                optionText="name"
                                onChange={(e: any) => setSelectedHeadingId(e.target.value)}
                                fullWidth
                                label="Heading"
                            />
                        </ReferenceInput>
                    </SimpleForm>
                </CardContent>
            </Card>

            {selectedHeadingId && (
                <DraggableList
                    resource="concepts"
                    title="Reorder Concepts"
                    parentFilterField="heading_id"
                    parentFilterValue={selectedHeadingId}
                />
            )}
        </Box>
    );
}
