def read_coe_file(coe_file_path):
    with open(coe_file_path, 'r') as file:
        lines = file.readlines()

    # Skip the header lines
    data_lines = lines[2:]

    # Remove the last semicolon and split by commas
    data = ''.join(data_lines).replace(';', '').split(',')

    # Convert the binary strings to integers
    data_array = [int(value.strip(), 16) for value in data]

    return data_array

def separate_rgb(data_array):
    rgb_values = []
    for value in data_array:
        red = (value >> 8) & 0xF  # Extract the first 4 bits
        green = (value >> 4) & 0xF  # Extract the next 4 bits
        blue = value & 0xF  # Extract the last 4 bits
        rgb_values.append((red, green, blue))
    return rgb_values

def average_rgb(rgb_values):
    total_red = total_green = total_blue = 0
    for red, green, blue in rgb_values:
        total_red += red
        total_green += green
        total_blue += blue

    count = len(rgb_values)
    avg_red = total_red / count
    avg_green = total_green / count
    avg_blue = total_blue / count

    return avg_red, avg_green, avg_blue

# Example usage
coe_file_path = "../coe/grass.coe"
data_array = read_coe_file(coe_file_path)
rgb_values = separate_rgb(data_array)
avg_red, avg_green, avg_blue = average_rgb(rgb_values)
print(f"Average Red: {avg_red}, Average Green: {avg_green}, Average Blue: {avg_blue}")