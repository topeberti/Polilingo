import { createTheme } from '@mui/material/styles';

// Polilingo color palette based on documentation
export const theme = createTheme({
    palette: {
        primary: {
            main: '#1E3A8A', // Dark Blue (Police style)
            contrastText: '#ffffff',
        },
        secondary: {
            main: '#F59E0B', // Gold/Yellow (Badge style)
            contrastText: '#000000',
        },
        success: {
            main: '#10B981', // Green (for Active/Correct)
        },
        error: {
            main: '#EF4444', // Red (for Archived/Errors)
        },
        background: {
            default: '#F3F4F6',
            paper: '#FFFFFF',
        },
    },
    typography: {
        fontFamily: [
            '-apple-system',
            'BlinkMacSystemFont',
            '"Segoe UI"',
            'Roboto',
            '"Helvetica Neue"',
            'Arial',
            'sans-serif',
        ].join(','),
        h1: {
            fontWeight: 600,
        },
        h2: {
            fontWeight: 600,
        },
        h3: {
            fontWeight: 600,
        },
    },
    components: {
        MuiAppBar: {
            styleOverrides: {
                root: {
                    backgroundColor: '#1E3A8A',
                },
            },
        },
        MuiButton: {
            styleOverrides: {
                root: {
                    textTransform: 'none',
                    borderRadius: 8,
                },
            },
        },
        MuiCard: {
            styleOverrides: {
                root: {
                    borderRadius: 12,
                    boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                },
            },
        },
    },
});
