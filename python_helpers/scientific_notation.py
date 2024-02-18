def scientific_to_binary(scientific_notation):
    # Splitting the scientific notation string
    coefficient, exponent = scientific_notation.split('e+')
    coefficient = coefficient.replace('.', '')  # Removing the decimal point
    exponent = int(exponent)

    # Adding leading zeros if necessary to make it 24 bits
    coefficient_binary = '0' * (23 - exponent) + coefficient

    # Add ending 0s
    final_24_bit = coefficient_binary + '0' * (24 - len(coefficient_binary))
    return  final_24_bit

def process_file(input_file, output_file):
    with open(input_file, 'r') as f:
        numbers = f.readlines()

    binary_strings = [scientific_to_binary(number.strip()) for number in numbers]

    with open(output_file, 'w') as f:
        for binary_string in binary_strings:
            f.write(binary_string + '\n')
if __name__ == "__main__":
    input_file = "input_binary_test_data.txt"  
    output_file = "output_binary_test_data.txt"  
    process_file(input_file, output_file)