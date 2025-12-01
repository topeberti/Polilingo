import React, { useEffect, useState } from 'react';
import { useDataProvider } from 'react-admin';
import { Box, Typography, CircularProgress, Select, MenuItem, FormControl, FormHelperText } from '@mui/material';

interface HierarchyLevelSelectorProps {
    level: 'concept' | 'heading' | 'topic' | 'block';
    value: string | null;
    onChange: (value: string | null) => void;
    parentId?: string | null;
}

export const HierarchyLevelSelector: React.FC<HierarchyLevelSelectorProps> = ({
    level,
    value,
    onChange,
    parentId,
}) => {
    const dataProvider = useDataProvider();
    const [choices, setChoices] = useState<any[]>([]);
    const [loading, setLoading] = useState(false);

    const getResourceName = () => {
        switch (level) {
            case 'concept': return 'concepts';
            case 'heading': return 'headings';
            case 'topic': return 'topics';
            case 'block': return 'blocks';
        }
    };

    const getParentField = () => {
        switch (level) {
            case 'concept': return 'heading_id';
            case 'heading': return 'topic_id';
            case 'topic': return 'block_id';
            case 'block': return null;
        }
    };

    const getLabel = () => {
        switch (level) {
            case 'concept': return 'Select Concept';
            case 'heading': return 'Select Heading';
            case 'topic': return 'Select Topic';
            case 'block': return 'Select Block';
        }
    };

    const resourceName = getResourceName();
    const parentField = getParentField();

    // Fetch choices when component mounts or parent changes
    useEffect(() => {
        const fetchChoices = async () => {
            setLoading(true);
            try {
                const filter = parentField && parentId ? { [parentField]: parentId } : {};
                const { data } = await dataProvider.getList(resourceName, {
                    pagination: { page: 1, perPage: 1000 },
                    sort: { field: 'name', order: 'ASC' },
                    filter,
                });
                setChoices(data.map(item => ({ id: item.id, name: item.name })));
            } catch (error) {
                console.error(`Error fetching ${resourceName}:`, error);
                setChoices([]);
            } finally {
                setLoading(false);
            }
        };

        fetchChoices();
    }, [resourceName, parentField, parentId, dataProvider]);

    return (
        <Box sx={{ mb: 2 }}>
            <Typography variant="subtitle2" gutterBottom>
                {getLabel()}
            </Typography>
            {loading ? (
                <CircularProgress size={24} />
            ) : (
                <FormControl fullWidth>
                    <Select
                        value={value || ''}
                        onChange={(e) => onChange(e.target.value || null)}
                        displayEmpty
                    >
                        <MenuItem value="">
                            <em>None</em>
                        </MenuItem>
                        {choices.map((choice) => (
                            <MenuItem key={choice.id} value={choice.id}>
                                {choice.name}
                            </MenuItem>
                        ))}
                    </Select>
                    <FormHelperText>
                        {`Select from available ${level}s${parentId ? ' in the selected parent' : ''}`}
                    </FormHelperText>
                </FormControl>
            )}
        </Box>
    );
};
