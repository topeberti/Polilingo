import React from 'react';
import { Box, Card, CardContent, Typography, Alert, CircularProgress, Chip } from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import WarningIcon from '@mui/icons-material/Warning';
import ErrorIcon from '@mui/icons-material/Error';

interface QuestionPoolPreviewProps {
    questionCount: number | null;
    isLoading: boolean;
    requiredQuestions: number;
    error?: string;
}

export const QuestionPoolPreview: React.FC<QuestionPoolPreviewProps> = ({
    questionCount,
    isLoading,
    requiredQuestions,
    error,
}) => {
    const getStatusColor = () => {
        if (questionCount === null || questionCount === 0) return 'error';
        if (questionCount < requiredQuestions) return 'warning';
        return 'success';
    };

    const getStatusIcon = () => {
        const color = getStatusColor();
        if (color === 'error') return <ErrorIcon />;
        if (color === 'warning') return <WarningIcon />;
        return <CheckCircleIcon />;
    };

    const getStatusMessage = () => {
        if (questionCount === null) return 'No selection made yet';
        if (questionCount === 0) return 'No questions match your criteria';
        if (questionCount < requiredQuestions) {
            return `Only ${questionCount} question${questionCount === 1 ? '' : 's'} available (need ${requiredQuestions})`;
        }
        return `${questionCount} question${questionCount === 1 ? '' : 's'} available`;
    };

    return (
        <Card variant="outlined" sx={{ mb: 2 }}>
            <CardContent>
                <Typography variant="h6" gutterBottom>
                    Question Pool Preview
                </Typography>

                {isLoading ? (
                    <Box display="flex" alignItems="center" gap={1}>
                        <CircularProgress size={20} />
                        <Typography variant="body2">Loading question count...</Typography>
                    </Box>
                ) : error ? (
                    <Alert severity="error" sx={{ mt: 1 }}>
                        {error}
                    </Alert>
                ) : (
                    <Box>
                        <Box display="flex" alignItems="center" gap={1} sx={{ mb: 2 }}>
                            <Chip
                                icon={getStatusIcon()}
                                label={getStatusMessage()}
                                color={getStatusColor()}
                                variant="outlined"
                            />
                        </Box>

                        {questionCount !== null && questionCount < requiredQuestions && questionCount > 0 && (
                            <Alert severity="warning" sx={{ mt: 1 }}>
                                The session requires {requiredQuestions} questions, but only {questionCount} match your criteria.
                                You may want to broaden your selection or reduce the number of required questions.
                            </Alert>
                        )}

                        {questionCount === 0 && (
                            <Alert severity="error" sx={{ mt: 1 }}>
                                No questions found. Please adjust your selection criteria or difficulty range.
                            </Alert>
                        )}

                        {questionCount !== null && questionCount >= requiredQuestions && (
                            <Alert severity="success" sx={{ mt: 1 }}>
                                Perfect! You have enough questions for this session.
                            </Alert>
                        )}
                    </Box>
                )}
            </CardContent>
        </Card>
    );
};
