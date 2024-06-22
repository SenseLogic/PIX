/*
    This file is part of the Sprout distribution.

    https://github.com/senselogic/SPROUT

    Copyright (C) 2017 Eric Pelzer (ecstatic.coder@gmail.com)

    Sprout is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Sprout is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Sprout.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import arsd.color : Color, MemoryImage, TrueColorImage;
import arsd.png : readPng;
import core.stdc.stdlib : exit;
import std.conv : to;
import std.file : write;
import std.stdio : writeln;
import std.string : endsWith, indexOf, join, replace, split, startsWith;

// -- TYPES

// ~~

struct PIXEL
{
    // -- ATTRIBUTES

    ubyte
        Red,
        Green,
        Blue,
        Opacity;

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

    ubyte GetLightness(
        )
    {
        return ( ( ( ( 306L * Red + 601L * Green + 117L * Blue ) >> 10 ) * Opacity ) / 255 ).to!ubyte();
    }
}

// ~~

struct IMAGE
{
    // -- ATTRIBUTES

    ubyte[]
        ByteArray;
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

    void WriteCFile(
        string c_file_path
        )
    {
        long
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

        for ( first_row_index = 0;
              first_row_index < RowCount;
              first_row_index += SpriteRowCount )
        {
            post_row_index = first_row_index + SpriteRowCount;

            for ( first_column_index = 0;
                  first_column_index < ColumnCount;
                  first_column_index += SpriteColumnCount )
            {
                post_column_index = first_column_index + SpriteColumnCount;

                sprite_byte_text = "";

                for ( row_index = first_row_index;
                      row_index < post_row_index;
                      ++row_index )
                {
                    sprite_byte_text ~= "            ";

                    for ( column_index = first_column_index;
                          column_index < post_column_index;
                          ++column_index )
                    {
                        if ( ( column_index & 7 ) == 0 )
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
                            pixel = PixelArray[ pixel_index ];
                        }
                        else
                        {
                            pixel.Clear();
                        }

                        if ( ( pixel.GetLightness() < PixelMinimumLightness ) != InvertOptionIsEnabled )
                        {
                            sprite_byte_text ~= "0";
                        }
                        else
                        {
                            sprite_byte_text ~= "1";
                        }
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

                sprite_row_byte_count = ( SpriteColumnCount + 7 ) >> 3;
                sprite_byte_count = SpriteRowCount * sprite_row_byte_count;

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

                if ( ColumnCount > SpriteColumnCount
                     || RowCount > SpriteRowCount )
                {
                    c_file_text
                       ~= "_"
                          ~ ( first_row_index / SpriteRowCount ).to!string()
                          ~ "_"
                          ~ ( first_column_index / SpriteColumnCount ).to!string();
                }

                c_file_text ~= "[ " ~ sprite_byte_count.to!string() ~ " ] =\n        {\n";
                c_file_text ~= sprite_byte_text;
                c_file_text ~= "        },\n";
            }
        }

        c_file_path.WriteText( c_file_text[ 0 .. $ - 2 ] ~ ";\n" );
    }
}

// -- VARIABLES

bool
    InvertOptionIsEnabled,
    TrimOptionIsEnabled;
long
    PixelMinimumLightness,
    SpriteColumnCount,
    SpriteRowCount;

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

void ConvertImage(
    string png_file_path,
    string c_file_path
    )
{
    IMAGE
        image;

    image.ReadPngFile( png_file_path );
    image.WriteCFile( c_file_path );
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        option;

    argument_array = argument_array[ 1 .. $ ];

    PixelMinimumLightness = 128;
    SpriteColumnCount = 24;
    SpriteRowCount = 21;
    InvertOptionIsEnabled = false;
    TrimOptionIsEnabled = false;

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];

        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--pixel-minimum-lightness"
             && argument_array.length >= 1 )
        {
            PixelMinimumLightness = argument_array[ 0 ].to!long();

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--sprite-column-count"
                  && argument_array.length >= 1 )
        {
            SpriteColumnCount = argument_array[ 0 ].to!long();

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--sprite-row-count"
                  && argument_array.length >= 1 )
        {
            SpriteRowCount = argument_array[ 0 ].to!long();

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--invert"
                  && argument_array.length >= 1 )
        {
            InvertOptionIsEnabled = true;
        }
        else if ( option == "--trim"
                  && argument_array.length >= 1 )
        {
            TrimOptionIsEnabled = true;
        }
        else
        {
            Abort( "Invalid option : " ~ option );
        }
    }

    if ( argument_array.length == 1
         && argument_array[ 0 ].endsWith( ".png" ) )
    {
        ConvertImage( argument_array[ 0 ], argument_array[ 0 ][ 0 .. $ - 4 ] ~ ".c" );
    }
    else if ( argument_array.length == 2
              && argument_array[ 0 ].endsWith( ".png" )
              && argument_array[ 1 ].endsWith( ".c" ) )
    {
        ConvertImage( argument_array[ 0 ], argument_array[ 1 ] );
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    sprout [options] sprite.png" );
        writeln( "    sprout [options] sprite.png sprite.c" );
        writeln( "Options :" );
        writeln( "    --pixel-minimum-lightness pixel_minimum_lightness" );
        writeln( "    --sprite-column-count sprite_column_count" );
        writeln( "    --sprite-row-count sprite_row_count" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
