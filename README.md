# Melon Game

A simple Godot-based physics puzzle game where you combine fruits of the same type to create larger fruits.

## Recent Updates

### Fruit Appearance Update

- Changed the fruit appearance to use PNG images instead of simple colored meshes
- Used 11 different fruit textures from smallest to largest:
  1. Cherry
  2. Strawberry
  3. Grape
  4. Orange
  5. Persimmon
  6. Apple
  7. Pear
  8. Peach
  9. Pineapple
  10. Melon
  11. Watermelon
- Updated the dropper to show fruit preview images
- Maintained physics and collision behavior

## How to Play

- Click to drop fruits
- Combine same-sized fruits to create larger ones
- Try to get the highest score without letting fruits stack to the top

## Technical Notes

- The fruit textures are stored in the `fruit_textures` directory
- Each fruit level has a specific texture assigned to it
- The game keeps the original color-based code as a fallback
