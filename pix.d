/*
    This file is part of the Pix distribution.

    https://github.com/senselogic/PIX

    Copyright (C) 2017 Eric Pelzer (ecstatic.coder@gmail.com)

    Pix is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Pix is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Pix.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import arsd.color : Color, MemoryImage, TrueColorImage;
import arsd.png : readPng, writePng;
import core.stdc.stdlib : exit;
import std.conv : to;
import std.file : write;
import std.stdio : writeln;
import std.string : endsWith, indexOf, join, replace, split, startsWith;

// -- TYPES

struct COLOR
{
    // -- ATTRIBUTES

    ubyte
        Red,
        Green,
        Blue,
        Opacity;

    // -- INQUIRIES

    ubyte GetLightness(
        )
    {
        return ( ( ( ( 306L * Red + 601L * Green + 117L * Blue ) >> 10 ) * Opacity ) / 255 ).to!ubyte();
    }

    // -- OPERATIONS

    void Clear(
        )
    {
        Red = 0;
        Green = 0;
        Blue = 0;
        Opacity = 0;
    }

    // ~~

    void Set(
        ubyte red,
        ubyte green,
        ubyte blue,
        ubyte opacity = 255
        )
    {
        Red = red;
        Green = green;
        Blue = blue;
        Opacity = opacity;
    }

    // ~~

    void Binarize(
        ubyte minimum_lightness
        )
    {
        ubyte
            lightness;

        lightness = GetLightness();

        if ( lightness < minimum_lightness )
        {
            Set( 0, 0, 0 );
        }
        else
        {
            Set( 255, 255, 255 );
        }
    }

    // ~~

    void Invert(
        )
    {
        Red = 255 - Red;
        Green = 255 - Green;
        Blue = 255 - Blue;
    }
}

// ~~

alias PIXEL = COLOR;

// ~~

struct IMAGE
{
    // -- ATTRIBUTES

    long
        ColumnCount,
        RowCount;
    PIXEL[]
        PixelArray;

    // -- INQUIRIES

    long GetPixelIndex(
        long column_index,
        long row_index
        )
    {
        if ( column_index >= 0
             && column_index < ColumnCount
             && row_index >= 0
             && row_index < RowCount )
        {
            return row_index * ColumnCount + column_index;
        }
        else
        {
            return -1;
        }
    }

    // ~~

    COLOR[] GetColorArray(
        )
    {
        bool
            color_is_missing;
        COLOR[]
            color_array;

        foreach ( pixel; PixelArray )
        {
            color_is_missing = true;

            foreach ( color; color_array )
            {
                if ( pixel == color )
                {
                    color_is_missing = false;

                    break;
                }
            }

            if ( color_is_missing )
            {
                color_array ~= pixel;
            }
        }

        return color_array;
    }

    // ~~

    void WritePngFile(
        string png_file_path
        )
    {
        long
            column_index,
            row_index,
            pixel_index;
        Color
            color;
        TrueColorImage
            true_color_image;
        PIXEL
            pixel;

        writeln( "Writing file : ", png_file_path );

        true_color_image = new TrueColorImage( cast( int )ColumnCount, cast( int )RowCount );

        for ( row_index = 0;
              row_index < RowCount;
              ++row_index )
        {
            for ( column_index = 0;
                  column_index < ColumnCount;
                  ++column_index )
            {
                pixel_index = GetPixelIndex( column_index, row_index );
                pixel = PixelArray[ pixel_index ];

                color.r = pixel.Red.to!ubyte();
                color.g = pixel.Green.to!ubyte();
                color.b = pixel.Blue.to!ubyte();
                color.a = 255;

                true_color_image.setPixel( cast( int )column_index, cast( int )row_index, color );
            }
        }

        writePng( png_file_path, true_color_image );
    }

    // ~~

    void WriteCFile(
        string c_file_path,
        long sprite_column_count,
        long sprite_row_count
        )
    {
        bool
            image_is_serialized;
        long
            bit_index,
            color_index,
            column_index,
            first_column_index,
            first_row_index,
            row_index,
            pixel_index,
            post_column_index,
            post_row_index,
            sprite_byte_count,
            sprite_row_byte_count;
        string
            c_file_text,
            sprite_byte_text,
            sprite_name;
        string[]
            sprite_line_array;
        PIXEL
            pixel;

        sprite_name = c_file_path.GetLogicalPath().split( '/' )[ $ - 1 ][ 0 .. $ - 2 ];
        c_file_text ~= "uint8_t\n";

        if ( sprite_column_count == 0 )
        {
            sprite_column_count = ColumnCount;
        }

        if ( sprite_row_count == 0 )
        {
            sprite_row_count = PixelArray.length / sprite_column_count;
        }

        for ( first_row_index = 0;
              first_row_index < RowCount;
              first_row_index += sprite_row_count * RowStep )
        {
            post_row_index = first_row_index + sprite_row_count;

            for ( first_column_index = 0;
                  first_column_index < ColumnCount;
                  first_column_index += sprite_column_count * ColumnStep )
            {
                post_column_index = first_column_index + sprite_column_count;

                sprite_byte_text = "";

                for ( row_index = first_row_index;
                      row_index < post_row_index;
                      row_index += RowStep )
                {
                    sprite_byte_text ~= "            ";
                    bit_index = 0;

                    for ( column_index = first_column_index;
                          column_index < post_column_index;
                          column_index += ColumnStep )
                    {
                        if ( ( bit_index & 7 ) == 0 )
                        {
                            if ( column_index == first_column_index )
                            {
                                sprite_byte_text ~= "0b";
                            }
                            else
                            {
                                sprite_byte_text ~= ", 0b";
                            }
                        }

                        pixel_index = GetPixelIndex( column_index, row_index );

                        if ( pixel_index >= 0 )
                        {
                            color_index = PixelArray[ pixel_index ].GetColorIndex();
                        }
                        else
                        {
                            color_index = 0;
                        }

                        sprite_byte_text ~= color_index.GetBinaryText( ColorBitCount );

                        bit_index += ColorBitCount;
                    }

                    if ( row_index < post_row_index - 1 )
                    {
                        sprite_byte_text ~= ",\n";
                    }
                    else
                    {
                        sprite_byte_text ~= "\n";
                    }
                }

                sprite_row_byte_count = ( sprite_column_count + 7 ) >> 3;
                sprite_byte_count = sprite_row_count * sprite_row_byte_count;

                if ( TrimOptionIsEnabled )
                {
                    sprite_line_array = sprite_byte_text.split( '\n' );

                    while ( sprite_line_array.length > 0
                            && sprite_line_array[ 0 ].startsWith( "            0b" )
                            && sprite_line_array[ 0 ].indexOf( '1' ) < 0 )
                    {
                        sprite_line_array = sprite_line_array[ 1 .. $ ];
                        sprite_byte_count -= sprite_row_byte_count;
                    }

                    sprite_byte_text = sprite_line_array.join( '\n' );
                }

                c_file_text ~= "    " ~ sprite_name;

                if ( ColumnCount > sprite_column_count
                     || RowCount > sprite_row_count )
                {
                    c_file_text
                       ~= "_"
                          ~ ( first_row_index / sprite_row_count ).to!string()
                          ~ "_"
                          ~ ( first_column_index / sprite_column_count ).to!string();
                }

                c_file_text
                    ~= "[ " ~ sprite_byte_count.to!string() ~ " ] =\n        {\n"
                       ~ sprite_byte_text
                       ~ "        },\n";
            }
        }

        c_file_path.WriteText( c_file_text[ 0 .. $ - 2 ] ~ ";\n" );
    }

    // -- OPERATIONS

    void ReadPngFile(
        string png_file_path
        )
    {
        long
            column_index,
            row_index,
            pixel_index;
        Color
            color;
        TrueColorImage
            true_color_image;
        PIXEL
            pixel;

        writeln( "Reading file : ", png_file_path );

        true_color_image = readPng( png_file_path ).getAsTrueColorImage();

        RowCount = true_color_image.height();
        ColumnCount = true_color_image.width();
        PixelArray.length = RowCount * ColumnCount;

        for ( row_index = 0;
              row_index < RowCount;
              ++row_index )
        {
            for ( column_index = 0;
                  column_index < ColumnCount;
                  ++column_index )
            {
                color = true_color_image.getPixel( cast( int )column_index, cast( int )row_index );

                pixel.Red = color.r;
                pixel.Green = color.g;
                pixel.Blue = color.b;
                pixel.Opacity = color.a;

                pixel_index = GetPixelIndex( column_index, row_index );
                PixelArray[ pixel_index ] = pixel;
            }
        }
    }

    // ~~

    void Binarize(
        ubyte minimum_lightness
        )
    {
        foreach ( ref pixel; PixelArray )
        {
            pixel.Binarize( minimum_lightness );
        }
    }

    // ~~

    void Invert(
        )
    {
        foreach ( ref pixel; PixelArray )
        {
            pixel.Invert();
        }
    }

    // ~~

    void Tile(
        long tile_column_count,
        long tile_row_count
        )
    {
        bool
            columns_are_flipped,
            rows_are_flipped;
        long
            column_index,
            first_column_index,
            first_row_index,
            pixel_index,
            row_index;
        PIXEL
            transparent_pixel;
        PIXEL[]
            pixel_array;

        columns_are_flipped = ( tile_column_count < 0 );

        if ( columns_are_flipped )
        {
            tile_column_count = -tile_column_count;
        }

        rows_are_flipped = ( tile_row_count < 0 );

        if ( rows_are_flipped )
        {
            tile_row_count = -tile_row_count;
        }

        for ( first_row_index = 0;
              first_row_index < RowCount;
              first_row_index += tile_row_count )
        {
            for ( first_column_index = 0;
                  first_column_index < ColumnCount;
                  first_column_index += tile_column_count )
            {
                for ( row_index = 0;
                      row_index < tile_row_count;
                      ++row_index )
                {
                    for ( column_index = 0;
                          column_index < tile_column_count;
                          ++column_index )
                    {
                        if ( columns_are_flipped )
                        {
                            if ( rows_are_flipped )
                            {
                                pixel_index = GetPixelIndex( first_column_index + tile_column_count - 1 - column_index, first_row_index + tile_row_count - 1 - row_index );
                            }
                            else
                            {
                                pixel_index = GetPixelIndex( first_column_index + tile_column_count - 1 - column_index, first_row_index + row_index );
                            }
                        }
                        else
                        {
                            if ( rows_are_flipped )
                            {
                                pixel_index = GetPixelIndex( first_column_index + column_index, first_row_index + tile_row_count - 1 - row_index );
                            }
                            else
                            {
                                pixel_index = GetPixelIndex( first_column_index + column_index, first_row_index + row_index );
                            }
                        }

                        if ( pixel_index >= 0 )
                        {
                            pixel_array ~= PixelArray[ pixel_index ];
                        }
                        else
                        {
                            pixel_array ~= transparent_pixel;
                        }
                    }
                }
            }
        }

        ColumnCount = tile_column_count;
        RowCount = pixel_array.length / tile_column_count;
        PixelArray = pixel_array;
    }

    // ~~

    void Flatten(
        long column_count
        )
    {
        ColumnCount = column_count;
        RowCount = PixelArray.length / column_count;
    }
}

// -- VARIABLES

bool
    TrimOptionIsEnabled;
long
    ColorBitCount,
    ColumnStep,
    RowStep,
    sprite_column_count,
    sprite_row_count;
COLOR[]
    ColorArray;
IMAGE
    Image;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

string GetBinaryText(
    ulong natural,
    ulong minimum_character_count
    )
{
    string
        binary_text;

    binary_text = natural.to!string( 2 );

    while ( binary_text.length < minimum_character_count )
    {
        binary_text = '0' ~ binary_text;
    }

    return binary_text;
}

// ~~

string GetPhysicalPath(
    string path
    )
{
    return path.replace( '/', '\\' );
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( '\\', '/' );
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    writeln( "Writing file : ", file_path );

    try
    {
        file_path.GetPhysicalPath().write( file_text );
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

long GetColorIndex(
    COLOR color
    )
{
    foreach ( color_index, palette_color; ColorArray )
    {
        if ( color == palette_color )
        {
            return color_index;
        }
    }

    return 0;
}

// ~~

void ReadPalettePngFile(
    string png_file_path
    )
{
    IMAGE
        image;

    image.ReadPngFile( png_file_path );
    ColorArray = image.GetColorArray();
    ColorBitCount = 1;

    while ( ( 1 << ColorBitCount ) < ColorArray.length )
    {
        ++ColorBitCount;
    }
}

// ~~

void ReadPngFile(
    string png_file_path,
    long column_step,
    long row_step
    )
{
    Image.ReadPngFile( png_file_path );
    ColumnStep = column_step;
    RowStep = row_step;
}

// ~~

void BinarizeImage(
    ubyte minimum_lightness
    )
{
    Image.Binarize( minimum_lightness );
}

// ~~

void InvertImage(
    )
{
    Image.Invert();
}

// ~~

void TileImage(
    long tile_column_count,
    long tile_row_count
    )
{
    Image.Tile( tile_column_count, tile_row_count );
}

// ~~

void FlattenImage(
    long column_count
    )
{
    Image.Flatten( column_count );
}

// ~~

void WritePngFile(
    string png_file_path
    )
{
    Image.WritePngFile( png_file_path );
}

// ~~

void WriteCFile(
    string c_file_path,
    long sprite_column_count,
    long sprite_row_count
    )
{
    Image.WriteCFile(
        c_file_path,
        sprite_column_count,
        sprite_row_count
        );
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        option;

    argument_array = argument_array[ 1 .. $ ];

    ColorArray.length = 2;
    ColorArray[ 0 ].Set( 0, 0, 0 );
    ColorArray[ 1 ].Set( 255, 255, 255 );
    ColorBitCount = 1;
    ColumnStep = 1;
    RowStep = 1;
    TrimOptionIsEnabled = false;

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];

        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--read-palette-png"
             && argument_array.length >= 1 )
        {
            ReadPalettePngFile( argument_array[ 0 ] );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--read-png"
                  && argument_array.length >= 3 )
        {
            ReadPngFile(
                argument_array[ 0 ],
                argument_array[ 1 ].to!long(),
                argument_array[ 2 ].to!long()
                );

            argument_array = argument_array[ 3 .. $ ];
        }
        else if ( option == "--binarize"
                  && argument_array.length >= 1 )
        {
            BinarizeImage( argument_array[ 0 ].to!ubyte() );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--invert" )
        {
            InvertImage();
        }
        else if ( option == "--tile"
                  && argument_array.length >= 2 )
        {
            TileImage(
                argument_array[ 0 ].to!long(),
                argument_array[ 1 ].to!long()
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--flatten"
                  && argument_array.length >= 1 )
        {
            FlattenImage(
                argument_array[ 0 ].to!long()
                );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--trim" )
        {
            TrimOptionIsEnabled = true;
        }
        else if ( option == "--write-png"
                  && argument_array.length >= 1 )
        {
            WritePngFile( argument_array[ 0 ] );

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--write-c"
                  && argument_array.length >= 3 )
        {
            WriteCFile(
                argument_array[ 0 ],
                argument_array[ 1 ].to!long(),
                argument_array[ 2 ].to!long()
                );

            argument_array = argument_array[ 3 .. $ ];
        }
        else
        {
            Abort( "Invalid option : " ~ option );
        }
    }

    if ( argument_array.length > 0 )
    {
        writeln( "Usage :" );
        writeln( "    pix [options]" );
        writeln( "    pix [options]" );
        writeln( "Options :" );
        writeln( "    --read-palette-png palette.png" );
        writeln( "    --read-png sprite.png column_step row_step" );
        writeln( "    --binarize threshold" );
        writeln( "    --invert" );
        writeln( "    --tile tile_column_count tile_row_count" );
        writeln( "    --flatten column_count" );
        writeln( "    --trim" );
        writeln( "    --write-c sprite.c sprite_column_count sprite_row_count" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}




