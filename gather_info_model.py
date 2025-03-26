import onnx
import argparse
import sys
import os

def gather_model_info(model_path, output_file):
    try:
        # Load the ONNX model
        model = onnx.load(model_path)
        
        # Open the output file
        with open(output_file, 'w') as f:
            # Write file name
            f.write(f"File Name: {os.path.basename(model_path)}\n\n")
            
            # Write model information
            f.write(f"Model Name: {model.graph.name}\n")
            f.write(f"Opset Import Version: {model.opset_import[0].version}\n\n")
            
            # Write input information
            f.write("Inputs:\n")
            for input in model.graph.input:
                f.write(f"  Name: {input.name}\n")
                f.write(f"  Shape: {[dim.dim_value if dim.dim_value else 'dynamic' for dim in input.type.tensor_type.shape.dim]}\n")
                f.write(f"  Data Type: {onnx.TensorProto.DataType.Name(input.type.tensor_type.elem_type)}\n\n")
            
            # Write output information
            f.write("Outputs:\n")
            for output in model.graph.output:
                f.write(f"  Name: {output.name}\n")
                f.write(f"  Shape: {[dim.dim_value if dim.dim_value else 'dynamic' for dim in output.type.tensor_type.shape.dim]}\n")
                f.write(f"  Data Type: {onnx.TensorProto.DataType.Name(output.type.tensor_type.elem_type)}\n\n")
            
        print(f"Model information has been written to {output_file}")
    
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Gather information about an ONNX model")
    parser.add_argument("model_path", help="Path to the ONNX model file")
    parser.add_argument("--output", default="info_model.txt", help="Output file name (default: info_model.txt)")
    
    args = parser.parse_args()
    
    gather_model_info(args.model_path, args.output)