/*
  # Gallery Schema Setup

  1. New Tables
    - `images`
      - `id` (uuid, primary key)
      - `title` (text)
      - `url` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `categories`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `created_at` (timestamp)
    
    - `tags`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `created_at` (timestamp)
    
    - `image_categories`
      - `image_id` (uuid, foreign key)
      - `category_id` (uuid, foreign key)
      - Primary key is (image_id, category_id)
    
    - `image_tags`
      - `image_id` (uuid, foreign key)
      - `tag_id` (uuid, foreign key)
      - Primary key is (image_id, tag_id)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Create images table
CREATE TABLE IF NOT EXISTS images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create tags table
CREATE TABLE IF NOT EXISTS tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create image_categories junction table
CREATE TABLE IF NOT EXISTS image_categories (
  image_id uuid REFERENCES images(id) ON DELETE CASCADE,
  category_id uuid REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (image_id, category_id)
);

-- Create image_tags junction table
CREATE TABLE IF NOT EXISTS image_tags (
  image_id uuid REFERENCES images(id) ON DELETE CASCADE,
  tag_id uuid REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (image_id, tag_id)
);

-- Enable RLS
ALTER TABLE images ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE image_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE image_tags ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow public read access to images"
  ON images FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public read access to categories"
  ON categories FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public read access to tags"
  ON tags FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public read access to image_categories"
  ON image_categories FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public read access to image_tags"
  ON image_tags FOR SELECT
  TO public
  USING (true);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updating updated_at
CREATE TRIGGER update_images_updated_at
  BEFORE UPDATE ON images
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();