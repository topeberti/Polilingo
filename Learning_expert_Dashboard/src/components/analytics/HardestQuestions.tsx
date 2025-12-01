import { Box, Typography, Paper } from '@mui/material';
import { Title } from 'react-admin';

export const HardestQuestions = () => {
    return (
        <Box sx={{ p: 3 }}>
            <Title title="Hardest Questions Report" />
            <Typography variant="h4" gutterBottom>
                Hardest Questions
            </Typography>
            <Paper sx={{ p: 3, mt: 2 }}>
                <Typography variant="body1" color="text.secondary">
                    This report will show questions with the lowest correct answer percentage.
                    Requires user_session_history data to calculate accuracy rates.
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                    Features:
                    • Questions sorted by correct answer percentage (lowest first)
                    • Filter by concept/topic
                    • Quick link to edit poorly performing questions
                    • Identify questions that may be poorly worded
                </Typography>
            </Paper>
        </Box>
    );
};
