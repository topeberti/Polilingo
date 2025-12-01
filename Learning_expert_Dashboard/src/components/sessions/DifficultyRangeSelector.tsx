import React from 'react';
import { Box, Typography, Slider } from '@mui/material';

interface DifficultyRangeSelectorProps {
    minDifficulty: number | null;
    maxDifficulty: number | null;
    onChange: (min: number | null, max: number | null) => void;
}

export const DifficultyRangeSelector: React.FC<DifficultyRangeSelectorProps> = ({
    minDifficulty,
    maxDifficulty,
    onChange,
}) => {
    const [value, setValue] = React.useState<number[]>([
        minDifficulty || 1,
        maxDifficulty || 10,
    ]);

    // Sync slider value with props when they change (e.g., when editing an existing session)
    React.useEffect(() => {
        if (minDifficulty !== null || maxDifficulty !== null) {
            setValue([
                minDifficulty || 1,
                maxDifficulty || 10,
            ]);
        }
    }, [minDifficulty, maxDifficulty]);

    const handleChange = (_event: Event, newValue: number | number[]) => {
        const range = newValue as number[];
        setValue(range);
        onChange(range[0], range[1]);
    };

    return (
        <Box sx={{ mb: 3, px: 1 }}>
            <Typography variant="subtitle2" gutterBottom>
                Question Difficulty Range (Optional)
            </Typography>
            <Typography variant="caption" color="text.secondary" gutterBottom display="block">
                Select difficulty range from 1 (easiest) to 10 (hardest)
            </Typography>
            <Box sx={{ px: 2, pt: 1 }}>
                <Slider
                    value={value}
                    onChange={handleChange}
                    valueLabelDisplay="on"
                    min={1}
                    max={10}
                    marks={[
                        { value: 1, label: '1' },
                        { value: 5, label: '5' },
                        { value: 10, label: '10' },
                    ]}
                />
            </Box>
            <Typography variant="body2" sx={{ mt: 1 }}>
                Selected range: {value[0]} - {value[1]}
            </Typography>
        </Box>
    );
};
