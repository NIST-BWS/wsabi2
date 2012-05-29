This code has changes to bound the cell drag operation at the edges of the grid.

The bounds checking is done in GMGridView.m. Four properties (dragBufferLeft, etc.) have been added,
and the calculations are performed in the method:
- (void)sortingPanGestureUpdated:(UIPanGestureRecognizer *)panGesture
