# Cell Tracker

Given an mp4 video of a cell, we repreent each frame as a grayscale matrix and convert the matrix into a black-and-white Sobel object. We fill in the region defined the cell border and determine the region's centroid and area. To track the movement of a cell across frames, we predict the cell's next position with a 4th-order finite difference method. The cell whose centroid is found near the predicted point is determined to be the same cell.
