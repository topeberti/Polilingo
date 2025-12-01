import { Box, Typography, Paper } from '@mui/material';
import { Title } from 'react-admin';

export const DropOffAnalysis = () => {
    return (
        <Box sx={{ p: 3 }}>
            <Title title="Drop-Off Analysis" />
            <Typography variant="h4" gutterBottom>
                Lesson Drop-Off Analysis
            </Typography>
            <Paper sx={{ p: 3, mt: 2 }}>
                <Typography variant="body1" color="text.secondary">
                    This report identifies lessons with high abandonment rates.
                    Requires user_progress data to analyze completion patterns.
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                    Metrics:
                    • Percentage of users who start but don't complete each lesson
                    • Average attempts before completion
                    • Time spent vs completion rate
                    • Lessons that may need difficulty adjustment
                </Typography>
            </Paper>
        </Box>
    );
};
