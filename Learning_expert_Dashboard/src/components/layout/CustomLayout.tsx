import { Layout, LayoutProps } from 'react-admin';
import { ReactNode } from 'react';

interface CustomLayoutProps extends LayoutProps {
    children: ReactNode;
}

export const CustomLayout = (props: CustomLayoutProps) => {
    return <Layout {...props} />;
};
