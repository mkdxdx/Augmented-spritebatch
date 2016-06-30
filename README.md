# Augmented-spritebatch
helper class for love2d engine to make spritebatches more flexible

Basically has same functionality like vanilla spritebatch, except it aims to help with attachAttribute usage. 
Also can track vertices of it's own mesh so user doesn't have to create separate one to modify sprites in his project, which is nice.

Also has sprite release function so if sprite is not needed anymore, it's id is now free and will be returned on next sprite add operation. Because expanding buffer size with mesh recreation is too much of a bottleneck.

More in example and in code comments.
