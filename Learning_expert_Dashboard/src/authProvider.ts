import { AuthProvider } from 'react-admin';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export const authProvider: AuthProvider = {
    login: async ({ username, password }) => {
        const { error } = await supabase.auth.signInWithPassword({
            email: username,
            password: password,
        });

        if (error) {
            throw new Error(error.message);
        }
    },

    logout: async () => {
        const { error } = await supabase.auth.signOut();
        if (error) {
            throw new Error(error.message);
        }
    },

    checkAuth: async () => {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session) {
            throw new Error('Not authenticated');
        }
    },

    checkError: (error) => {
        const status = error.status;
        if (status === 401 || status === 403) {
            return Promise.reject();
        }
        return Promise.resolve();
    },

    getIdentity: async () => {
        const { data: { user } } = await supabase.auth.getUser();

        if (user) {
            return {
                id: user.id,
                fullName: user.email,
                avatar: user.user_metadata?.avatar_url,
            };
        }

        throw new Error('Not authenticated');
    },

    getPermissions: async () => {
        const { data: { user } } = await supabase.auth.getUser();

        // Check if user is admin based on metadata or role table
        const role = user?.user_metadata?.role || 'content_admin';
        return role;
    },
};
