import { Box, Typography, Paper } from '@mui/material';
import { Title } from 'react-admin';

export const SyllabusTreeView = () => {
    return (
        <Box sx={{ p: 3 }}>
            <Title title="Syllabus Tree View" />
            <Typography variant="h4" gutterBottom>
                Syllabus Tree View
            </Typography>
            <Paper sx={{ p: 3, mt: 2 }}>
                <Typography variant="body1" color="text.secondary">
                    The hierarchical tree view with drag-and-drop functionality will be implemented here.
                    For the MVP, use the standard resource views to manage Blocks → Topics → Headings → Concepts.
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                    This component will feature:
                    • Expandable/collapsible tree structure
                    • Drag-and-drop reordering
                    • Question count badges per concept
                    • Quick edit/delete actions
                </Typography>
            </Paper>
        </Box>
    );
};
