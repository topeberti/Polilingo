import React, { useState, useEffect } from 'react';
import {
    useDataProvider,
    useNotify,
    Loading,
    Title,
} from 'react-admin';
import {
    DndContext,
    closestCenter,
    KeyboardSensor,
    PointerSensor,
    useSensor,
    useSensors,
    DragEndEvent,
} from '@dnd-kit/core';
import {
    arrayMove,
    SortableContext,
    sortableKeyboardCoordinates,
    useSortable,
    verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import {
    Box,
    Card,
    CardContent,
    Typography,
    Paper,
    Button,
} from '@mui/material';
import DragIndicatorIcon from '@mui/icons-material/DragIndicator';
import SaveIcon from '@mui/icons-material/Save';
import { useNavigate } from 'react-router-dom';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';

interface DraggableItem {
    id: number;
    name: string;
    order: number;
}

interface SortableItemProps {
    id: number;
    name: string;
}

function SortableItem({ id, name }: SortableItemProps) {
    const {
        attributes,
        listeners,
        setNodeRef,
        transform,
        transition,
        isDragging,
    } = useSortable({ id });

    const style = {
        transform: CSS.Transform.toString(transform),
        transition,
        opacity: isDragging ? 0.5 : 1,
    };

    return (
        <Paper
            ref={setNodeRef}
            style={style}
            sx={{
                p: 2,
                mb: 1,
                cursor: 'move',
                display: 'flex',
                alignItems: 'center',
                '&:hover': {
                    backgroundColor: 'action.hover',
                },
            }}
        >
            <DragIndicatorIcon
                {...attributes}
                {...listeners}
                sx={{ mr: 2, color: 'action.active' }}
            />
            <Typography>{name}</Typography>
        </Paper>
    );
}

interface DraggableListProps {
    resource: string;
    title: string;
    parentFilterField?: string;
    parentFilterValue?: number | null;
}

export function DraggableList({
    resource,
    title,
    parentFilterField,
    parentFilterValue,
}: DraggableListProps) {
    const [items, setItems] = useState<DraggableItem[]>([]);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [hasChanges, setHasChanges] = useState(false);
    const dataProvider = useDataProvider();
    const notify = useNotify();
    const navigate = useNavigate();

    const sensors = useSensors(
        useSensor(PointerSensor),
        useSensor(KeyboardSensor, {
            coordinateGetter: sortableKeyboardCoordinates,
        })
    );

    useEffect(() => {
        loadItems();
    }, [parentFilterValue]);

    const loadItems = async () => {
        setLoading(true);
        try {
            const filter: any = {};
            if (parentFilterField && parentFilterValue) {
                filter[parentFilterField] = parentFilterValue;
            }

            const { data } = await dataProvider.getList(resource, {
                pagination: { page: 1, perPage: 1000 },
                sort: { field: 'order', order: 'ASC' },
                filter,
            });

            setItems(data as DraggableItem[]);
            setHasChanges(false);
        } catch (error: any) {
            notify(`Error loading items: ${error.message}`, { type: 'error' });
        } finally {
            setLoading(false);
        }
    };

    const handleDragEnd = (event: DragEndEvent) => {
        const { active, over } = event;

        if (over && active.id !== over.id) {
            setItems((items) => {
                const oldIndex = items.findIndex((item) => item.id === active.id);
                const newIndex = items.findIndex((item) => item.id === over.id);

                const newItems = arrayMove(items, oldIndex, newIndex);

                // Update order values to match new positions
                const updatedItems = newItems.map((item, index) => ({
                    ...item,
                    order: index + 1,
                }));

                setHasChanges(true);
                return updatedItems;
            });
        }
    };

    const handleSave = async () => {
        setSaving(true);
        try {
            // @ts-ignore - custom method
            await dataProvider.batchUpdateOrder(resource, {
                data: items.map((item) => ({
                    id: item.id,
                    order: item.order,
                })),
            });

            notify('Order updated successfully', { type: 'success' });
            setHasChanges(false);
        } catch (error: any) {
            notify(`Error saving order: ${error.message}`, { type: 'error' });
        } finally {
            setSaving(false);
        }
    };

    const handleBack = () => {
        navigate(`/${resource}`);
    };

    if (loading) {
        return <Loading />;
    }

    return (
        <Box sx={{ p: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Title title={title} />
                <Box>
                    <Button
                        startIcon={<ArrowBackIcon />}
                        onClick={handleBack}
                        sx={{ mr: 2 }}
                    >
                        Back to List
                    </Button>
                    <Button
                        variant="contained"
                        color="primary"
                        startIcon={<SaveIcon />}
                        onClick={handleSave}
                        disabled={!hasChanges || saving}
                    >
                        {saving ? 'Saving...' : 'Save Order'}
                    </Button>
                </Box>
            </Box>

            {items.length === 0 ? (
                <Card>
                    <CardContent>
                        <Typography color="textSecondary">
                            No items to reorder. Please create some items first.
                        </Typography>
                    </CardContent>
                </Card>
            ) : (
                <Card>
                    <CardContent>
                        <Typography variant="body2" color="textSecondary" sx={{ mb: 2 }}>
                            Drag and drop items to reorder them, then click "Save Order" to persist changes.
                        </Typography>
                        <DndContext
                            sensors={sensors}
                            collisionDetection={closestCenter}
                            onDragEnd={handleDragEnd}
                        >
                            <SortableContext
                                items={items.map((item) => item.id)}
                                strategy={verticalListSortingStrategy}
                            >
                                {items.map((item) => (
                                    <SortableItem key={item.id} id={item.id} name={item.name} />
                                ))}
                            </SortableContext>
                        </DndContext>
                    </CardContent>
                </Card>
            )}
        </Box>
    );
}
