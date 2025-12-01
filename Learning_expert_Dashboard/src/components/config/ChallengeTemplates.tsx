import { Box, Typography } from '@mui/material';
import { Title } from 'react-admin';

export const ChallengeTemplates = () => {
    return (
        <Box sx={{ p: 3 }}>
            <Title title="Challenge Templates" />
            <Typography variant="h4" gutterBottom>
                Challenge Templates
            </Typography>
            <Typography variant="body1" color="text.secondary">
                Use the Challenges resource to edit challenge templates. This page is a placeholder for a dedicated challenge editor UI.
            </Typography>
        </Box>
    );
};
