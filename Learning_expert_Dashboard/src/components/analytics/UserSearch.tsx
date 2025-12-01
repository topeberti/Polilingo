import { Box, Typography, Paper, TextField, Button } from '@mui/material';
import { Title } from 'react-admin';
import { useState } from 'react';

export const UserSearch = () => {
    const [searchQuery, setSearchQuery] = useState('');

    const handleSearch = () => {
        // TODO: Implement user search
        alert(`Searching for: ${searchQuery}`);
    };

    return (
        <Box sx={{ p: 3 }}>
            <Title title="User Search" />
            <Typography variant="h4" gutterBottom>
                User Search & Progress Viewer
            </Typography>

            <Paper sx={{ p: 3, mt: 2 }}>
                <Typography variant="body1" gutterBottom>
                    Search for users by email or username to view their progress
                </Typography>

                <Box sx={{ display: 'flex', gap: 2, mt: 2 }}>
                    <TextField
                        fullWidth
                        label="Email or Username"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        placeholder="user@example.com"
                    />
                    <Button variant="contained" onClick={handleSearch}>
                        Search
                    </Button>
                </Box>

                <Typography variant="body2" color="text.secondary" sx={{ mt: 3 }}>
                    This tool allows you to:
                    • Look up specific users for debugging
                    • View their lesson progress
                    • See their answer history
                    • Identify support issues
                </Typography>
            </Paper>
        </Box>
    );
};
