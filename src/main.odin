package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

read_input_file :: proc(index: int) -> (string, bool) 
{
    // Create filename
    file_name : string;
    {
        inputs_prefix  :: "..\\inputs\\";
        inputs_postfix :: ".txt";
        
        builder := strings.make_builder();
        strings.write_string(&builder, inputs_prefix);
        strings.write_int(&builder, index);
        strings.write_string(&builder, inputs_postfix);

        file_name = strings.to_string(builder);
    }
    
    // Read from file
    data, success := os.read_entire_file(file_name);
    if !success do return "", success;
    return string(data), success;
}

read_user_input :: proc(data: []byte, length: int) -> bool 
{
    index := 0;
    for index < length
    {
        _, input_err := os.read(os.stdin, data[index:index+1]);
        if input_err != 0
        {
            return true;
        }

        // Line feed
        if data[index] == 10 
        {
            return false;
        }
        index = index + 1;
    }

    return false;
}

day_one :: proc(input: string) 
{
    pt2 :: true;
    position := 1;
    reached_basement := false;

    floor : int;
    for c in input 
    {
        if c == '(' do floor = floor + 1;
        else
        if c == ')' do floor = floor - 1;
        else
        do fmt.println("Invalid character:", c);

        if pt2 && !reached_basement
        {
            if floor < 0 
            {
                fmt.println("Reached basement at position:", position);
                reached_basement = true;
            }
            position = position + 1;
        }
    }

    fmt.println("Final floor: ", floor);
}

min :: proc(a: int, b: int, c: int) -> int
{ 
    m := a;
    if b < m do m = b;
    if c < m do m = c;
    return m;
}

day_two :: proc(input: string) 
{
    pt2 :: true;
    
    // Array of l,w,h, l,w,h, ...
    box_sizes := make([dynamic]int);
    defer delete(box_sizes);

    // Parse individual numbers via slicing
    num_start_index := 0;
    char_index := 0;
    
    for c in input 
    {
        switch c 
        {
            case 'x':
                fallthrough;
            case '\n':
                size := strconv.atoi(input[num_start_index : char_index]);
                append(&box_sizes, size);
                num_start_index = char_index + 1;
        }
        char_index = char_index + 1;
    }

    // Calculate surface areas + slack
    wrapping_paper := 0;
    ribbon := 0;

    for box_index := 0; box_index < len(box_sizes); box_index = box_index + 3
    {
        l := box_sizes[box_index];
        w := box_sizes[box_index + 1];
        h := box_sizes[box_index + 2];

        l_w := l * w;
        w_h := w * h;
        l_h := l * h;

        surface := 2 * (l_w + w_h + l_h);
        slack := min(l_w, w_h, l_h);

        wrapping_paper += surface + slack;

        if pt2
        {
            perimeter_l_w := 2 * (l + w);
            perimeter_w_h := 2 * (w + h);
            perimeter_l_h := 2 * (l + h);

            ribbon = ribbon + min(perimeter_l_w, perimeter_w_h, perimeter_l_h) + l * w * h;
        }
    }

    fmt.println("Total wrapping paper required:", wrapping_paper, "sq ft.");
    if pt2 do fmt.println("Total ribbon needed:", ribbon, "ft.");
}

print_binary :: proc(num: int)
{
    bit_mask : int = 1 << 62;
    i : uint = 62;
    for
    {
        digit := (num & bit_mask) >> i;
        fmt.print(digit);
        bit_mask = bit_mask >> 1;
        if i == 0 
        {
            fmt.println();
            return;
        }
        i = i - 1;
    }
}

// Custom hashing algorithm, putting y into left 32 bits and x into right 32 bits
hash_2D :: proc(x: int, y: int) -> i64
{
    mask_32 := 1 << 32 - 1;

    x_32 := i64(x & mask_32);
    y_32 := i64(y & mask_32);

    hash : i64 = y_32 << 32 + x_32;

    return hash;
}


day_three :: proc(input: string)
{
    pt2 :: false;

    // Record coordinates as we go
    m := make(map[i64]int);

    x := 0;
    y := 0;
    houses := 1;

    // Record visiting 0
    m[hash_2D(x, y)] = 1;

    for c in input 
    {
        switch c 
        {
            case '^':
                y = y + 1;
            case 'v':
                y = y - 1;
            case '>':
                x = x + 1;
            case '<':
                x = x - 1;
        }
        fmt.print("Visiting", x, ",", y);

        hash := hash_2D(x, y);
        fmt.print(" Hash:", hash);

        exists := hash in m;
        if !exists 
        {
            m[hash] = 1;
            houses = houses + 1;
            fmt.print(" new", houses);
        }
        fmt.println();
    }

    fmt.println("Unique houses visited:", houses);
}

main :: proc() 
{
    user_input := make([]byte, 4);

    for 
    {
        // Get user input
        fmt.print("Enter day number of puzzle to solve: ");
        input_err := read_user_input(user_input, 4);

        if input_err
        {
            fmt.println("Error reading input");
        }

        // Check for attempted exit
        lower_user_input := strings.to_lower(string(user_input));
        if lower_user_input == "stop" || lower_user_input == "exit"
        {
            return;
        }
        delete(lower_user_input);

        day_number, ok := strconv.parse_int(string(user_input));
        if !ok 
        {
            fmt.println("Please enter a valid number day");
            continue;
        }

        input, read_success := read_input_file(day_number);
        if !read_success
        {
            fmt.println("Error occurred while reading input file");
            continue;
        }

        switch (day_number)
        {
            case 1:
                day_one(input);
            case 2:
                day_two(input);
            case 3:
                day_three(input);
            case 4..25:
                fmt.println("Day not implemented");
            case :
                fmt.println("Please enter a valid number day");
        }

        delete(input);
    }
}