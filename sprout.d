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
import std.string : endsWith, replace;

// -- TYPES

// ~~

struct PIXEL
{
    // -- ATTRIBUTES

    long
        Red,
        Green,
        Blue,
        Opacity;
}

// ~~

struct IMAGE
{
    // -- ATTRIBUTES

    ubyte[]
        ByteArray;
    long
        ColumnCount,
        LineCount;
    PIXEL[]
        PixelArray;

    // -- INQUIRIES

    long GetPixelIndex(
        long column_index,
        long line_index
        )
    {
        return line_index * ColumnCount + column_index;
    }

    // ~~

    long GetCheckedPixelIndex(
        long column_index,
        long line_index
        )
    {
        if ( column_index >= 0
             && column_index < ColumnCount
             && line_index >= 0
             && line_index < LineCount )
        {
            return line_index * ColumnCount + column_index;
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
            line_index,
            pixel_index;
        Color
            color;
        TrueColorImage
            true_color_image;
        PIXEL
            pixel;

        writeln( "Reading PNG file : ", png_file_path );

        true_color_image = readPng( png_file_path ).getAsTrueColorImage();

        LineCount = true_color_image.height();
        ColumnCount = true_color_image.width();
        PixelArray.length = LineCount * ColumnCount;

        for ( line_index = 0;
              line_index < LineCount;
              ++line_index )
        {
            for ( column_index = 0;
                  column_index < ColumnCount;
                  ++column_index )
            {
                color = true_color_image.getPixel( cast( int )column_index, cast( int )line_index );

                pixel.Red = color.r;
                pixel.Green = color.g;
                pixel.Blue = color.b;
                pixel.Opacity = color.a;

                pixel_index = GetPixelIndex( column_index, line_index );
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
            first_line_index,
            line_index,
            pixel_index,
            post_column_index,
            post_line_index;
        string
            c_file_text;
        PIXEL
            pixel;

        writeln( "Writing C file : ", c_file_path );

        c_file_text = "";

        for ( first_line_index = 0;
              first_line_index < LineCount;
              first_line_index += 21 )
        {
            post_line_index = first_line_index + 21;

            if ( post_line_index > LineCount )
            {
                post_line_index = LineCount;
            }

            for ( first_column_index = 0;
                  first_column_index < ColumnCount;
                  first_column_index += 24 )
            {
                post_column_index = first_column_index + 24;

                if ( post_column_index > ColumnCount )
                {
                    post_column_index = ColumnCount;
                }

                for ( line_index = first_line_index;
                      line_index < post_line_index;
                      ++line_index )
                {
                    for ( column_index = first_column_index;
                          column_index < post_column_index;
                          ++column_index )
                    {
                        if ( ( column_index & 7 ) == 0 )
                        {
                            if ( column_index == first_column_index )
                            {
                                c_file_text ~= "0b";
                            }
                            else
                            {
                                c_file_text ~= ", 0b";
                            }
                        }

                        pixel_index = GetPixelIndex( column_index, line_index );
                        pixel = PixelArray[ pixel_index ];

                        if ( pixel.Red + pixel.Green + pixel.Blue < 128 * 3 )
                        {
                            c_file_text ~= "0";
                        }
                        else
                        {
                            c_file_text ~= "1";
                        }
                    }

                    if ( line_index < post_line_index - 1 )
                    {
                        c_file_text ~= ",\n";
                    }
                    else
                    {
                        c_file_text ~= "\n";
                    }
                }

                c_file_text ~= "\n";
            }
        }

        c_file_path.WriteText( c_file_text );
    }
}

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
    argument_array = argument_array[ 1 .. $ ];

    if ( argument_array.length == 2
         && argument_array[ 0 ].endsWith( ".png" )
         && argument_array[ 1 ].endsWith( ".c" ) )
    {
        ConvertImage( argument_array[ 0 ], argument_array[ 1 ] );
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    sprout image.png sprites.c" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
