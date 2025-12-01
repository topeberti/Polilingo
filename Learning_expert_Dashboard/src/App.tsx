import { Admin, Resource, CustomRoutes } from 'react-admin';
import { Route } from 'react-router-dom';
import { dataProvider } from './providers/supabaseDataProvider';
import { authProvider } from './authProvider';
import { theme } from './theme';
import { Dashboard } from './components/layout/Dashboard';

// Resources
import { BlockList, BlockEdit, BlockCreate } from './resources/blocks';
import { TopicList, TopicEdit, TopicCreate } from './resources/topics';
import { HeadingList, HeadingEdit, HeadingCreate } from './resources/headings';
import { ConceptList, ConceptEdit, ConceptCreate } from './resources/concepts';
import { QuestionList, QuestionEdit, QuestionCreate } from './resources/questions';
import { LessonList, LessonEdit, LessonCreate } from './resources/lessons';
import { SessionList, SessionEdit, SessionCreate } from './resources/sessions';
import { ChallengeTemplateList, ChallengeTemplateEdit, ChallengeTemplateCreate } from './resources/challenges';
import { AppConfigurationList, AppConfigurationEdit, AppConfigurationCreate } from './resources/app_configuration';

// Ordering Pages
import { BlockOrdering } from './pages/ordering/BlockOrdering';
import { TopicOrdering } from './pages/ordering/TopicOrdering';
import { HeadingOrdering } from './pages/ordering/HeadingOrdering';
import { ConceptOrdering } from './pages/ordering/ConceptOrdering';
import { LessonOrdering } from './pages/ordering/LessonOrdering';
import { SessionOrdering } from './pages/ordering/SessionOrdering';

// Icons
import ViewModuleIcon from '@mui/icons-material/ViewModule';
import CategoryIcon from '@mui/icons-material/Category';
import TitleIcon from '@mui/icons-material/Title';
import LightbulbIcon from '@mui/icons-material/Lightbulb';
import QuestionAnswerIcon from '@mui/icons-material/QuestionAnswer';
import SchoolIcon from '@mui/icons-material/School';
import TimerIcon from '@mui/icons-material/Timer';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import SettingsIcon from '@mui/icons-material/Settings';

function App() {
    return (
        <Admin
            dataProvider={dataProvider}
            authProvider={authProvider}
            dashboard={Dashboard}
            theme={theme}
            title="Polilingo Learning Expert Dashboard"
        >
            {/* Syllabus Structure */}
            <Resource
                name="blocks"
                list={BlockList}
                edit={BlockEdit}
                create={BlockCreate}
                icon={ViewModuleIcon}
                options={{ label: 'Blocks' }}
            />
            <Resource
                name="topics"
                list={TopicList}
                edit={TopicEdit}
                create={TopicCreate}
                icon={CategoryIcon}
                options={{ label: 'Topics' }}
            />
            <Resource
                name="headings"
                list={HeadingList}
                edit={HeadingEdit}
                create={HeadingCreate}
                icon={TitleIcon}
                options={{ label: 'Headings' }}
            />
            <Resource
                name="concepts"
                list={ConceptList}
                edit={ConceptEdit}
                create={ConceptCreate}
                icon={LightbulbIcon}
                options={{ label: 'Concepts' }}
            />

            {/* Content */}
            <Resource
                name="questions"
                list={QuestionList}
                edit={QuestionEdit}
                create={QuestionCreate}
                icon={QuestionAnswerIcon}
                options={{ label: 'Questions' }}
            />

            {/* Learning Path */}
            <Resource
                name="lessons"
                list={LessonList}
                edit={LessonEdit}
                create={LessonCreate}
                icon={SchoolIcon}
                options={{ label: 'Lessons' }}
            />
            <Resource
                name="sessions"
                list={SessionList}
                edit={SessionEdit}
                create={SessionCreate}
                icon={TimerIcon}
                options={{ label: 'Sessions' }}
            />

            {/* Gamification */}
            <Resource
                name="challenge_templates"
                list={ChallengeTemplateList}
                edit={ChallengeTemplateEdit}
                create={ChallengeTemplateCreate}
                icon={EmojiEventsIcon}
                options={{ label: 'Challenges' }}
            />
            <Resource
                name="app_configuration"
                list={AppConfigurationList}
                edit={AppConfigurationEdit}
                create={AppConfigurationCreate}
                icon={SettingsIcon}
                options={{ label: 'App Config' }}
            />

            {/* Custom Routes for Ordering Pages */}
            <CustomRoutes>
                <Route path="/blocks/order" element={<BlockOrdering />} />
                <Route path="/topics/order" element={<TopicOrdering />} />
                <Route path="/headings/order" element={<HeadingOrdering />} />
                <Route path="/concepts/order" element={<ConceptOrdering />} />
                <Route path="/lessons/order" element={<LessonOrdering />} />
                <Route path="/sessions/order" element={<SessionOrdering />} />
            </CustomRoutes>
        </Admin>
    );
}

export default App;
