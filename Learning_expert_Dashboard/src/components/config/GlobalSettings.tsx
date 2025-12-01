import { Box, Typography, Paper, TextField, Button, Grid } from '@mui/material';
import { Title } from 'react-admin';
import { useState } from 'react';

export const GlobalSettings = () => {
    const [settings, setSettings] = useState({
        dailyGoalDefault: 100,
        xpMultiplier: 1.0,
        retryPenalty: 0,
        spacedRepetitionIntervals: '1, 3, 7, 14, 30',
    });

    const handleSave = () => {
        // TODO: Save to app_configuration table
        alert('Settings saved successfully!');
    };

    return (
        <Box sx={{ p: 3 }}>
            <Title title="Global Settings" />
            <Typography variant="h4" gutterBottom>
                Global Settings
            </Typography>

            <Paper sx={{ p: 3, mt: 2 }}>
                <Typography variant="h6" gutterBottom>
                    Gamification Parameters
                </Typography>

                <Grid container spacing={3} sx={{ mt: 1 }}>
                    <Grid item xs={12} md={6}>
                        <TextField
                            fullWidth
                            label="Daily XP Goal (Default)"
                            type="number"
                            value={settings.dailyGoalDefault}
                            onChange={(e) => setSettings({ ...settings, dailyGoalDefault: Number(e.target.value) })}
                        />
                    </Grid>


                    <Grid item xs={12} md={6}>
                        <TextField
                            fullWidth
                            label="XP Multiplier"
                            type="number"
                            inputProps={{ step: '0.1' }}
                            value={settings.xpMultiplier}
                            onChange={(e) => setSettings({ ...settings, xpMultiplier: Number(e.target.value) })}
                        />
                    </Grid>

                    <Grid item xs={12} md={6}>
                        <TextField
                            fullWidth
                            label="Retry Penalty (XP)"
                            type="number"
                            value={settings.retryPenalty}
                            onChange={(e) => setSettings({ ...settings, retryPenalty: Number(e.target.value) })}
                        />
                    </Grid>

                    <Grid item xs={12}>
                        <TextField
                            fullWidth
                            label="Spaced Repetition Intervals (days, comma-separated)"
                            value={settings.spacedRepetitionIntervals}
                            onChange={(e) => setSettings({ ...settings, spacedRepetitionIntervals: e.target.value })}
                            helperText="Example: 1, 3, 7, 14, 30"
                        />
                    </Grid>

                    <Grid item xs={12}>
                        <Button variant="contained" color="primary" onClick={handleSave}>
                            Save Settings
                        </Button>
                    </Grid>
                </Grid>
            </Paper>
        </Box>
    );
};
