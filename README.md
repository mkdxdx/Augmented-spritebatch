# Augmented-spritebatch
helper class for love2d engine to make spritebatches more flexible

Basically has same functionality like vanilla spritebatch, except it aims to help with attachAttribute usage. 
Also can track vertices of it's own mesh so user doesn't have to create separate one to modify sprites in his project, which is nice.

Also has sprite release function so if sprite is not needed anymore, it's id is now free and will be returned on next sprite add operation. Because expanding buffer size with mesh recreation is too much of a bottleneck.

More in example file and among code comments.

PS: It doesn't track kx/ky shear variables if mesh mode is used. I don't use this feature in my projects so i didn't bother to learn math of how to do it. Feel free to suggest or fork the thing if you are interested.

PPS: On each sprite add, especially in mesh mode there should be a quad passed as function argument for UV calculation. Just create basic quad with texture dimensions and you're good to go. Quads are love, quads are life.
