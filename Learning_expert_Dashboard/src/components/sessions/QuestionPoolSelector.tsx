import React, { useState, useEffect } from 'react';
import { useDataProvider, useNotify } from 'react-admin';
import { Box, Button, Typography, Paper, Divider } from '@mui/material';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward';
import ArrowDownwardIcon from '@mui/icons-material/ArrowDownward';
import { HierarchyLevelSelector } from './HierarchyLevelSelector';
import { DifficultyRangeSelector } from './DifficultyRangeSelector';
import { QuestionPoolPreview } from './QuestionPoolPreview';

export interface PoolSelectionCriteria {
    block_id?: string | null;
    topic_id?: string | null;
    heading_id?: string | null;
    concept_id?: string | null;
    min_difficulty?: number | null;
    max_difficulty?: number | null;
}

interface QuestionPoolSelectorProps {
    value?: PoolSelectionCriteria;
    onChange: (value: PoolSelectionCriteria) => void;
    requiredQuestions: number;
}

type HierarchyLevel = 'concept' | 'heading' | 'topic' | 'block';

export const QuestionPoolSelector: React.FC<QuestionPoolSelectorProps> = ({
    value = {},
    onChange,
    requiredQuestions,
}) => {
    const dataProvider = useDataProvider();
    const notify = useNotify();

    // Determine initial level based on existing value
    const getInitialLevel = (): HierarchyLevel => {
        if (value.concept_id) return 'concept';
        if (value.heading_id) return 'heading';
        if (value.topic_id) return 'topic';
        if (value.block_id) return 'block';
        return 'concept'; // Default to most granular
    };

    const [currentLevel, setCurrentLevel] = useState<HierarchyLevel>(getInitialLevel());
    const [previewCount, setPreviewCount] = useState<number | null>(null);
    const [isLoading, setIsLoading] = useState(false);
    const [previewError, setPreviewError] = useState<string | undefined>(undefined);

    // Update level when value changes (e.g., when editing an existing session)
    useEffect(() => {
        const newLevel = getInitialLevel();
        if (newLevel !== currentLevel) {
            setCurrentLevel(newLevel);
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [value.concept_id, value.heading_id, value.topic_id, value.block_id]);

    // Update preview when criteria changes
    useEffect(() => {
        const fetchPreview = async () => {
            // Only fetch if we have at least one ID selected for the current level
            const hasSelection =
                (currentLevel === 'concept' && value.concept_id) ||
                (currentLevel === 'heading' && value.heading_id) ||
                (currentLevel === 'topic' && value.topic_id) ||
                (currentLevel === 'block' && value.block_id);

            if (!hasSelection) {
                setPreviewCount(null);
                return;
            }

            setIsLoading(true);
            setPreviewError(undefined);

            try {
                // @ts-ignore - custom method
                const { data } = await dataProvider.getQuestionCountByCriteria({
                    blockId: value.block_id,
                    topicId: value.topic_id,
                    headingId: value.heading_id,
                    conceptId: value.concept_id,
                    minDifficulty: value.min_difficulty,
                    maxDifficulty: value.max_difficulty,
                });
                setPreviewCount(data);
            } catch (error: any) {
                console.error('Error fetching question count:', error);
                setPreviewError(error.message);
                notify('Error checking question pool size', { type: 'warning' });
            } finally {
                setIsLoading(false);
            }
        };

        fetchPreview();
    }, [value, currentLevel, dataProvider, notify]);

    const handleLevelChange = (newLevel: HierarchyLevel) => {
        setCurrentLevel(newLevel);
        // Clear selection when switching levels to avoid confusion
        // We keep difficulty settings though
        onChange({
            ...value,
            block_id: null,
            topic_id: null,
            heading_id: null,
            concept_id: null,
        });
    };

    const handleSelectionChange = (id: string | null) => {
        const newCriteria = { ...value };

        // Reset all IDs first
        newCriteria.block_id = null;
        newCriteria.topic_id = null;
        newCriteria.heading_id = null;
        newCriteria.concept_id = null;

        // Set the ID for the current level
        if (id) {
            switch (currentLevel) {
                case 'concept': newCriteria.concept_id = id; break;
                case 'heading': newCriteria.heading_id = id; break;
                case 'topic': newCriteria.topic_id = id; break;
                case 'block': newCriteria.block_id = id; break;
            }
        }

        onChange(newCriteria);
    };

    const handleDifficultyChange = (min: number | null, max: number | null) => {
        onChange({
            ...value,
            min_difficulty: min,
            max_difficulty: max,
        });
    };

    const getParentLevel = (level: HierarchyLevel): HierarchyLevel | null => {
        switch (level) {
            case 'concept': return 'heading';
            case 'heading': return 'topic';
            case 'topic': return 'block';
            case 'block': return null;
        }
    };

    const getChildLevel = (level: HierarchyLevel): HierarchyLevel | null => {
        switch (level) {
            case 'block': return 'topic';
            case 'topic': return 'heading';
            case 'heading': return 'concept';
            case 'concept': return null;
        }
    };

    const parentLevel = getParentLevel(currentLevel);
    const childLevel = getChildLevel(currentLevel);

    return (
        <Paper variant="outlined" sx={{ p: 3, mt: 2, mb: 2, backgroundColor: '#f8f9fa' }}>
            <Typography variant="h6" gutterBottom color="primary">
                Question Pool Configuration
            </Typography>
            <Typography variant="body2" paragraph>
                Define the criteria for questions in this session. Questions will be randomly selected from the pool based on these rules.
            </Typography>

            <Divider sx={{ my: 2 }} />

            {/* Hierarchy Selection */}
            <Box sx={{ mb: 3 }}>
                <HierarchyLevelSelector
                    level={currentLevel}
                    value={
                        currentLevel === 'concept' ? value.concept_id :
                            currentLevel === 'heading' ? value.heading_id :
                                currentLevel === 'topic' ? value.topic_id :
                                    value.block_id
                    }
                    onChange={handleSelectionChange}
                />

                <Box display="flex" gap={2} mt={1}>
                    {parentLevel && (
                        <Button
                            size="small"
                            startIcon={<ArrowUpwardIcon />}
                            onClick={() => handleLevelChange(parentLevel)}
                        >
                            Select from {parentLevel}s instead
                        </Button>
                    )}

                    {childLevel && (
                        <Button
                            size="small"
                            startIcon={<ArrowDownwardIcon />}
                            onClick={() => handleLevelChange(childLevel)}
                        >
                            Select from {childLevel}s instead
                        </Button>
                    )}
                </Box>
            </Box>

            <Divider sx={{ my: 2 }} />

            {/* Difficulty Selection */}
            <DifficultyRangeSelector
                minDifficulty={value.min_difficulty || null}
                maxDifficulty={value.max_difficulty || null}
                onChange={handleDifficultyChange}
            />

            <Divider sx={{ my: 2 }} />

            {/* Preview */}
            <QuestionPoolPreview
                questionCount={previewCount}
                isLoading={isLoading}
                requiredQuestions={requiredQuestions}
                error={previewError}
            />
        </Paper>
    );
};
