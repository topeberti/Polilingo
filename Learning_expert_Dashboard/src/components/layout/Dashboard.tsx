import { useState, useEffect } from 'react';
import {
    Card,
    CardContent,
    Grid,
    Typography,
    Box,
    LinearProgress,
    Chip,
    Button,
    Paper,
    List,
    ListItem,
    ListItemText,
    Divider,
    Stack,
    alpha
} from '@mui/material';
import { useDataProvider, useRedirect } from 'react-admin';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import SchoolIcon from '@mui/icons-material/School';
import QuestionAnswerIcon from '@mui/icons-material/QuestionAnswer';
import CategoryIcon from '@mui/icons-material/Category';
import LightbulbIcon from '@mui/icons-material/Lightbulb';
import TimerIcon from '@mui/icons-material/Timer';
import AddIcon from '@mui/icons-material/Add';
import ArrowForwardIcon from '@mui/icons-material/ArrowForward';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import WarningIcon from '@mui/icons-material/Warning';

interface Stats {
    totalBlocks: number;
    totalTopics: number;
    totalHeadings: number;
    totalConcepts: number;
    totalQuestions: number;
    totalLessons: number;
    totalSessions: number;
    activeContent: number;
    draftContent: number;
    archivedContent: number;
}

interface RecentActivity {
    id: string;
    name: string;
    text?: string;
    type: string;
    status?: string;
    created_at: string;
}

interface LowQuestionItem {
    id: string;
    name: string;
    questionCount: number;
    type: 'concept' | 'lesson';
}

export const Dashboard = () => {
    const dataProvider = useDataProvider();
    const redirect = useRedirect();
    const [stats, setStats] = useState<Stats>({
        totalBlocks: 0,
        totalTopics: 0,
        totalHeadings: 0,
        totalConcepts: 0,
        totalQuestions: 0,
        totalLessons: 0,
        totalSessions: 0,
        activeContent: 0,
        draftContent: 0,
        archivedContent: 0,
    });
    const [recentQuestions, setRecentQuestions] = useState<RecentActivity[]>([]);
    const [recentLessons, setRecentLessons] = useState<RecentActivity[]>([]);
    const [lowQuestionItems, setLowQuestionItems] = useState<LowQuestionItem[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                setLoading(true);

                // Fetch counts for all resources
                const [
                    blocks,
                    topics,
                    headings,
                    concepts,
                    questions,
                    lessons,
                    sessions
                ] = await Promise.all([
                    dataProvider.getList('blocks', { pagination: { page: 1, perPage: 1 }, sort: { field: 'id', order: 'ASC' }, filter: {} }),
                    dataProvider.getList('topics', { pagination: { page: 1, perPage: 1 }, sort: { field: 'id', order: 'ASC' }, filter: {} }),
                    dataProvider.getList('headings', { pagination: { page: 1, perPage: 1 }, sort: { field: 'id', order: 'ASC' }, filter: {} }),
                    dataProvider.getList('concepts', { pagination: { page: 1, perPage: 1 }, sort: { field: 'id', order: 'ASC' }, filter: {} }),
                    dataProvider.getList('questions', { pagination: { page: 1, perPage: 1 }, sort: { field: 'id', order: 'ASC' }, filter: {} }),
                    dataProvider.getList('lessons', { pagination: { page: 1, perPage: 1 }, sort: { field: 'id', order: 'ASC' }, filter: {} }),
                    dataProvider.getList('sessions', { pagination: { page: 1, perPage: 1 }, sort: { field: 'id', order: 'ASC' }, filter: {} }),
                ]);

                // Fetch recent questions
                const recentQuestionsData = await dataProvider.getList('questions', {
                    pagination: { page: 1, perPage: 5 },
                    sort: { field: 'created_at', order: 'DESC' },
                    filter: {}
                });

                // Fetch recent lessons
                const recentLessonsData = await dataProvider.getList('lessons', {
                    pagination: { page: 1, perPage: 5 },
                    sort: { field: 'created_at', order: 'DESC' },
                    filter: {}
                });

                // Count active/draft/archived content
                let activeCount = 0;
                let draftCount = 0;
                let archivedCount = 0;

                const contentResources = [blocks, topics, headings, concepts, questions, lessons];

                for (const resource of contentResources) {
                    if (resource.data) {
                        resource.data.forEach((item: any) => {
                            if (item.status === 'active') activeCount++;
                            else if (item.status === 'draft') draftCount++;
                            else if (item.status === 'archived') archivedCount++;
                        });
                    }
                }

                setStats({
                    totalBlocks: blocks.total || 0,
                    totalTopics: topics.total || 0,
                    totalHeadings: headings.total || 0,
                    totalConcepts: concepts.total || 0,
                    totalQuestions: questions.total || 0,
                    totalLessons: lessons.total || 0,
                    totalSessions: sessions.total || 0,
                    activeContent: activeCount,
                    draftContent: draftCount,
                    archivedContent: archivedCount,
                });

                setRecentQuestions(recentQuestionsData.data as RecentActivity[]);
                setRecentLessons(recentLessonsData.data as RecentActivity[]);

                // Fetch concepts and lessons with low question counts
                const lowQuestionWarnings: LowQuestionItem[] = [];

                // Check concepts
                const allConcepts = await dataProvider.getList('concepts', {
                    pagination: { page: 1, perPage: 1000 },
                    sort: { field: 'id', order: 'ASC' },
                    filter: { status: 'active' }
                });

                for (const concept of allConcepts.data) {
                    const conceptQuestions = await dataProvider.getList('questions', {
                        pagination: { page: 1, perPage: 1 },
                        sort: { field: 'id', order: 'ASC' },
                        filter: { concept_id: concept.id }
                    });

                    if (conceptQuestions.total !== undefined && conceptQuestions.total < 10) {
                        lowQuestionWarnings.push({
                            id: concept.id,
                            name: concept.name,
                            questionCount: conceptQuestions.total,
                            type: 'concept'
                        });
                    }
                }


                setLowQuestionItems(lowQuestionWarnings);
            } catch (error) {
                console.error('Error fetching dashboard stats:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchStats();
    }, [dataProvider]);

    const StatCard = ({
        title,
        value,
        icon: Icon,
        color,
        subtitle,
        onClick
    }: {
        title: string;
        value: number;
        icon: any;
        color: string;
        subtitle?: string;
        onClick?: () => void;
    }) => (
        <Card
            variant="outlined"
            sx={{
                height: '100%',
                cursor: onClick ? 'pointer' : 'default',
                transition: 'all 0.2s',
                '&:hover': onClick ? {
                    transform: 'translateY(-4px)',
                    boxShadow: 3,
                } : {}
            }}
            onClick={onClick}
        >
            <CardContent>
                <Box display="flex" alignItems="center" justifyContent="space-between" mb={2}>
                    <Box
                        sx={{
                            backgroundColor: alpha(color, 0.1),
                            borderRadius: 2,
                            p: 1,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                        }}
                    >
                        <Icon sx={{ color, fontSize: 28 }} />
                    </Box>
                </Box>
                <Typography variant="h3" fontWeight="bold" color={color}>
                    {value.toLocaleString()}
                </Typography>
                <Typography variant="body2" color="text.secondary" mt={0.5}>
                    {title}
                </Typography>
                {subtitle && (
                    <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mt: 1 }}>
                        {subtitle}
                    </Typography>
                )}
            </CardContent>
        </Card>
    );

    const QuickAction = ({ title, description, icon: Icon, color, onClick }: {
        title: string;
        description: string;
        icon: any;
        color: string;
        onClick: () => void;
    }) => (
        <Paper
            elevation={0}
            sx={{
                p: 2,
                border: '1px solid',
                borderColor: 'divider',
                borderRadius: 2,
                cursor: 'pointer',
                transition: 'all 0.2s',
                '&:hover': {
                    borderColor: color,
                    backgroundColor: alpha(color, 0.02),
                    transform: 'translateX(4px)',
                }
            }}
            onClick={onClick}
        >
            <Stack direction="row" spacing={2} alignItems="center">
                <Box
                    sx={{
                        backgroundColor: alpha(color, 0.1),
                        borderRadius: 1.5,
                        p: 1.5,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                    }}
                >
                    <Icon sx={{ color, fontSize: 24 }} />
                </Box>
                <Box flex={1}>
                    <Typography variant="subtitle1" fontWeight="600">{title}</Typography>
                    <Typography variant="body2" color="text.secondary">{description}</Typography>
                </Box>
                <ArrowForwardIcon sx={{ color: 'text.secondary' }} />
            </Stack>
        </Paper>
    );

    if (loading) {
        return (
            <Box sx={{ p: 3 }}>
                <LinearProgress />
            </Box>
        );
    }

    const totalContent = stats.totalBlocks + stats.totalTopics + stats.totalHeadings +
        stats.totalConcepts + stats.totalQuestions + stats.totalLessons + stats.totalSessions;
    const completionRate = totalContent > 0
        ? Math.round((stats.activeContent / (stats.activeContent + stats.draftContent)) * 100)
        : 0;

    return (
        <Box sx={{ p: 3 }}>
            {/* Header */}
            <Box mb={4}>
                <Typography variant="h4" gutterBottom fontWeight="bold">
                    Welcome to Polilingo Dashboard
                </Typography>
                <Typography variant="body1" color="text.secondary">
                    Manage your learning content for the Spanish State Police exam
                </Typography>
            </Box>

            {/* Stats Overview */}
            <Grid container spacing={3} mb={4}>
                <Grid item xs={12} sm={6} md={3}>
                    <StatCard
                        title="Total Questions"
                        value={stats.totalQuestions}
                        icon={QuestionAnswerIcon}
                        color="#F59E0B"
                        onClick={() => redirect('/questions')}
                    />
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                    <StatCard
                        title="Lessons"
                        value={stats.totalLessons}
                        icon={SchoolIcon}
                        color="#1E3A8A"
                        onClick={() => redirect('/lessons')}
                    />
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                    <StatCard
                        title="Sessions"
                        value={stats.totalSessions}
                        icon={TimerIcon}
                        color="#10B981"
                        onClick={() => redirect('/sessions')}
                    />
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                    <StatCard
                        title="Concepts"
                        value={stats.totalConcepts}
                        icon={LightbulbIcon}
                        color="#8B5CF6"
                        onClick={() => redirect('/concepts')}
                    />
                </Grid>
            </Grid>

            <Grid container spacing={3} mb={4}>
                <Grid item xs={12} md={8}>
                    {/* Content Structure */}
                    <Card variant="outlined">
                        <CardContent>
                            <Typography variant="h6" fontWeight="bold" gutterBottom>
                                Content Structure
                            </Typography>
                            <Typography variant="body2" color="text.secondary" mb={3}>
                                Your syllabus hierarchy overview
                            </Typography>

                            <Grid container spacing={2}>
                                <Grid item xs={6} sm={3}>
                                    <Box textAlign="center" p={2}>
                                        <Typography variant="h4" fontWeight="bold" color="primary.main">
                                            {stats.totalBlocks}
                                        </Typography>
                                        <Typography variant="caption" color="text.secondary">
                                            Blocks
                                        </Typography>
                                    </Box>
                                </Grid>
                                <Grid item xs={6} sm={3}>
                                    <Box textAlign="center" p={2}>
                                        <Typography variant="h4" fontWeight="bold" color="secondary.main">
                                            {stats.totalTopics}
                                        </Typography>
                                        <Typography variant="caption" color="text.secondary">
                                            Topics
                                        </Typography>
                                    </Box>
                                </Grid>
                                <Grid item xs={6} sm={3}>
                                    <Box textAlign="center" p={2}>
                                        <Typography variant="h4" fontWeight="bold" color="success.main">
                                            {stats.totalHeadings}
                                        </Typography>
                                        <Typography variant="caption" color="text.secondary">
                                            Headings
                                        </Typography>
                                    </Box>
                                </Grid>
                                <Grid item xs={6} sm={3}>
                                    <Box textAlign="center" p={2}>
                                        <Typography variant="h4" fontWeight="bold" sx={{ color: '#8B5CF6' }}>
                                            {stats.totalConcepts}
                                        </Typography>
                                        <Typography variant="caption" color="text.secondary">
                                            Concepts
                                        </Typography>
                                    </Box>
                                </Grid>
                            </Grid>
                        </CardContent>
                    </Card>
                </Grid>

                <Grid item xs={12} md={4}>
                    {/* Content Status */}
                    <Card variant="outlined" sx={{ height: '100%' }}>
                        <CardContent>
                            <Typography variant="h6" fontWeight="bold" gutterBottom>
                                Content Status
                            </Typography>
                            <Typography variant="body2" color="text.secondary" mb={3}>
                                Publication progress
                            </Typography>

                            <Stack spacing={2}>
                                <Box>
                                    <Stack direction="row" justifyContent="space-between" mb={1}>
                                        <Stack direction="row" spacing={1} alignItems="center">
                                            <CheckCircleIcon sx={{ fontSize: 16, color: 'success.main' }} />
                                            <Typography variant="body2">Active</Typography>
                                        </Stack>
                                        <Typography variant="body2" fontWeight="600">
                                            {stats.activeContent}
                                        </Typography>
                                    </Stack>
                                    <LinearProgress
                                        variant="determinate"
                                        value={totalContent > 0 ? (stats.activeContent / totalContent) * 100 : 0}
                                        sx={{ height: 8, borderRadius: 1 }}
                                        color="success"
                                    />
                                </Box>

                                <Box>
                                    <Stack direction="row" justifyContent="space-between" mb={1}>
                                        <Stack direction="row" spacing={1} alignItems="center">
                                            <WarningIcon sx={{ fontSize: 16, color: 'warning.main' }} />
                                            <Typography variant="body2">Draft</Typography>
                                        </Stack>
                                        <Typography variant="body2" fontWeight="600">
                                            {stats.draftContent}
                                        </Typography>
                                    </Stack>
                                    <LinearProgress
                                        variant="determinate"
                                        value={totalContent > 0 ? (stats.draftContent / totalContent) * 100 : 0}
                                        sx={{ height: 8, borderRadius: 1 }}
                                        color="warning"
                                    />
                                </Box>

                                <Box>
                                    <Stack direction="row" justifyContent="space-between" mb={1}>
                                        <Stack direction="row" spacing={1} alignItems="center">
                                            <Box sx={{
                                                width: 16,
                                                height: 16,
                                                borderRadius: '50%',
                                                bgcolor: 'text.disabled'
                                            }} />
                                            <Typography variant="body2">Archived</Typography>
                                        </Stack>
                                        <Typography variant="body2" fontWeight="600">
                                            {stats.archivedContent}
                                        </Typography>
                                    </Stack>
                                    <LinearProgress
                                        variant="determinate"
                                        value={totalContent > 0 ? (stats.archivedContent / totalContent) * 100 : 0}
                                        sx={{ height: 8, borderRadius: 1 }}
                                        color="inherit"
                                    />
                                </Box>
                            </Stack>
                        </CardContent>
                    </Card>
                </Grid>
            </Grid>

            {/* Low Question Warnings */}
            {lowQuestionItems.length > 0 && (
                <Box mb={4}>
                    <Card
                        variant="outlined"
                        sx={{
                            borderColor: 'warning.main',
                            bgcolor: alpha('#F59E0B', 0.05)
                        }}
                    >
                        <CardContent>
                            <Stack direction="row" spacing={2} alignItems="flex-start" mb={2}>
                                <WarningIcon sx={{ color: 'warning.main', fontSize: 28 }} />
                                <Box flex={1}>
                                    <Typography variant="h6" fontWeight="bold" color="warning.dark" gutterBottom>
                                        ⚠️ Content Needs Attention
                                    </Typography>
                                    <Typography variant="body2" color="text.secondary">
                                        The following items have fewer than 10 questions. Consider adding more questions for better learning experience.
                                    </Typography>
                                </Box>
                            </Stack>

                            <Grid container spacing={2} mt={1}>
                                {lowQuestionItems.map((item) => (
                                    <Grid item xs={12} sm={6} md={4} key={`${item.type}-${item.id}`}>
                                        <Paper
                                            elevation={0}
                                            sx={{
                                                p: 2,
                                                border: '1px solid',
                                                borderColor: 'warning.light',
                                                borderRadius: 2,
                                                cursor: 'pointer',
                                                transition: 'all 0.2s',
                                                '&:hover': {
                                                    borderColor: 'warning.main',
                                                    transform: 'translateY(-2px)',
                                                    boxShadow: 2,
                                                }
                                            }}
                                            onClick={() => redirect(`/${item.type === 'concept' ? 'concepts' : 'lessons'}/${item.id}`)}
                                        >
                                            <Stack direction="row" justifyContent="space-between" alignItems="center">
                                                <Box flex={1} mr={1}>
                                                    <Chip
                                                        label={item.type === 'concept' ? 'Concept' : 'Lesson'}
                                                        size="small"
                                                        sx={{
                                                            mb: 1,
                                                            height: 20,
                                                            fontSize: '0.7rem',
                                                            bgcolor: 'warning.light',
                                                            color: 'warning.dark'
                                                        }}
                                                    />
                                                    <Typography variant="body2" fontWeight="600" noWrap>
                                                        {item.name}
                                                    </Typography>
                                                    <Typography variant="caption" color="warning.dark" fontWeight="600">
                                                        {item.questionCount} question{item.questionCount !== 1 ? 's' : ''}
                                                    </Typography>
                                                </Box>
                                                <ArrowForwardIcon sx={{ color: 'warning.main', fontSize: 20 }} />
                                            </Stack>
                                        </Paper>
                                    </Grid>
                                ))}
                            </Grid>
                        </CardContent>
                    </Card>
                </Box>
            )}

            {/* Quick Actions */}
            <Box mb={4}>
                <Typography variant="h6" fontWeight="bold" gutterBottom>
                    Quick Actions
                </Typography>
                <Grid container spacing={2} mt={1}>
                    <Grid item xs={12} sm={6} md={3}>
                        <QuickAction
                            title="Add Question"
                            description="Create new exam questions"
                            icon={AddIcon}
                            color="#F59E0B"
                            onClick={() => redirect('/questions/create')}
                        />
                    </Grid>
                    <Grid item xs={12} sm={6} md={3}>
                        <QuickAction
                            title="Create Lesson"
                            description="Build a new learning path"
                            icon={SchoolIcon}
                            color="#1E3A8A"
                            onClick={() => redirect('/lessons/create')}
                        />
                    </Grid>
                    <Grid item xs={12} sm={6} md={3}>
                        <QuickAction
                            title="Manage Syllabus"
                            description="Organize content hierarchy"
                            icon={CategoryIcon}
                            color="#10B981"
                            onClick={() => redirect('/blocks')}
                        />
                    </Grid>
                    <Grid item xs={12} sm={6} md={3}>
                        <QuickAction
                            title="Add Concept"
                            description="Create new learning concept"
                            icon={LightbulbIcon}
                            color="#8B5CF6"
                            onClick={() => redirect('/concepts/create')}
                        />
                    </Grid>
                </Grid>
            </Box>

            {/* Recent Activity */}
            <Grid container spacing={3}>
                <Grid item xs={12} md={6}>
                    <Card variant="outlined">
                        <CardContent>
                            <Stack direction="row" justifyContent="space-between" alignItems="center" mb={2}>
                                <Typography variant="h6" fontWeight="bold">
                                    Recent Questions
                                </Typography>
                                <Button
                                    size="small"
                                    endIcon={<ArrowForwardIcon />}
                                    onClick={() => redirect('/questions')}
                                >
                                    View All
                                </Button>
                            </Stack>

                            {recentQuestions.length > 0 ? (
                                <List disablePadding>
                                    {recentQuestions.map((question, index) => (
                                        <Box key={question.id}>
                                            <ListItem
                                                disablePadding
                                                sx={{
                                                    py: 1.5,
                                                    cursor: 'pointer',
                                                    '&:hover': { bgcolor: 'action.hover' },
                                                    borderRadius: 1
                                                }}
                                                onClick={() => redirect(`/questions/${question.id}`)}
                                            >
                                                <ListItemText
                                                    primary={
                                                        <Typography variant="body2" noWrap>
                                                            {question.name || question.text || `Question #${question.id}`}
                                                        </Typography>
                                                    }
                                                    secondary={
                                                        <Stack direction="row" spacing={1} alignItems="center" mt={0.5}>
                                                            {question.status && (
                                                                <Chip
                                                                    label={question.status}
                                                                    size="small"
                                                                    color={
                                                                        question.status === 'active' ? 'success' :
                                                                            question.status === 'draft' ? 'warning' : 'default'
                                                                    }
                                                                    sx={{ height: 20, fontSize: '0.7rem' }}
                                                                />
                                                            )}
                                                            <Typography variant="caption" color="text.secondary">
                                                                {new Date(question.created_at).toLocaleDateString()}
                                                            </Typography>
                                                        </Stack>
                                                    }
                                                />
                                            </ListItem>
                                            {index < recentQuestions.length - 1 && <Divider />}
                                        </Box>
                                    ))}
                                </List>
                            ) : (
                                <Box py={3} textAlign="center">
                                    <Typography variant="body2" color="text.secondary">
                                        No questions yet. Create your first question!
                                    </Typography>
                                    <Button
                                        variant="contained"
                                        startIcon={<AddIcon />}
                                        sx={{ mt: 2 }}
                                        onClick={() => redirect('/questions/create')}
                                    >
                                        Add Question
                                    </Button>
                                </Box>
                            )}
                        </CardContent>
                    </Card>
                </Grid>

                <Grid item xs={12} md={6}>
                    <Card variant="outlined">
                        <CardContent>
                            <Stack direction="row" justifyContent="space-between" alignItems="center" mb={2}>
                                <Typography variant="h6" fontWeight="bold">
                                    Recent Lessons
                                </Typography>
                                <Button
                                    size="small"
                                    endIcon={<ArrowForwardIcon />}
                                    onClick={() => redirect('/lessons')}
                                >
                                    View All
                                </Button>
                            </Stack>

                            {recentLessons.length > 0 ? (
                                <List disablePadding>
                                    {recentLessons.map((lesson, index) => (
                                        <Box key={lesson.id}>
                                            <ListItem
                                                disablePadding
                                                sx={{
                                                    py: 1.5,
                                                    cursor: 'pointer',
                                                    '&:hover': { bgcolor: 'action.hover' },
                                                    borderRadius: 1
                                                }}
                                                onClick={() => redirect(`/lessons/${lesson.id}`)}
                                            >
                                                <ListItemText
                                                    primary={
                                                        <Typography variant="body2" noWrap>
                                                            {lesson.name || `Lesson #${lesson.id}`}
                                                        </Typography>
                                                    }
                                                    secondary={
                                                        <Stack direction="row" spacing={1} alignItems="center" mt={0.5}>
                                                            {lesson.status && (
                                                                <Chip
                                                                    label={lesson.status}
                                                                    size="small"
                                                                    color={
                                                                        lesson.status === 'active' ? 'success' :
                                                                            lesson.status === 'draft' ? 'warning' : 'default'
                                                                    }
                                                                    sx={{ height: 20, fontSize: '0.7rem' }}
                                                                />
                                                            )}
                                                            <Typography variant="caption" color="text.secondary">
                                                                {new Date(lesson.created_at).toLocaleDateString()}
                                                            </Typography>
                                                        </Stack>
                                                    }
                                                />
                                            </ListItem>
                                            {index < recentLessons.length - 1 && <Divider />}
                                        </Box>
                                    ))}
                                </List>
                            ) : (
                                <Box py={3} textAlign="center">
                                    <Typography variant="body2" color="text.secondary">
                                        No lessons yet. Create your first lesson!
                                    </Typography>
                                    <Button
                                        variant="contained"
                                        startIcon={<AddIcon />}
                                        sx={{ mt: 2 }}
                                        onClick={() => redirect('/lessons/create')}
                                    >
                                        Create Lesson
                                    </Button>
                                </Box>
                            )}
                        </CardContent>
                    </Card>
                </Grid>
            </Grid>
        </Box>
    );
};
