import { Box, Button, Typography, Paper } from '@mui/material';
import { useState } from 'react';

export const BulkImport = () => {
    const [file, setFile] = useState<File | null>(null);

    const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        if (event.target.files && event.target.files[0]) {
            setFile(event.target.files[0]);
        }
    };

    const handleImport = () => {
        if (!file) {
            alert('Please select a file first');
            return;
        }
        // TODO: Implement CSV/Excel import using xlsx library
        alert(`File ${file.name} ready for import. CSV parsing will be implemented.`);
    };

    const handleExport = () => {
        // TODO: Implement question export
        alert('Export functionality will be implemented using xlsx library');
    };

    const downloadTemplate = () => {
        // TODO: Generate and download CSV template
        alert('CSV template download will be implemented');
    };

    return (
        <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
                Bulk Import/Export Questions
            </Typography>

            <Box sx={{ mb: 2 }}>
                <Button variant="outlined" onClick={downloadTemplate} sx={{ mb: 2 }}>
                    Download CSV Template
                </Button>
            </Box>

            <Box sx={{ mb: 2 }}>
                <input
                    type="file"
                    accept=".csv,.xlsx"
                    onChange={handleFileChange}
                    style={{ marginBottom: '1rem' }}
                />
                <Button variant="contained" onClick={handleImport} disabled={!file}>
                    Import Questions
                </Button>
            </Box>

            <Box>
                <Button variant="contained" color="secondary" onClick={handleExport}>
                    Export All Questions
                </Button>
            </Box>

            <Typography variant="caption" color="text.secondary" sx={{ mt: 2, display: 'block' }}>
                Note: CSV import/export functionality requires the xlsx library and will be fully implemented when connected to the database.
            </Typography>
        </Paper>
    );
};
