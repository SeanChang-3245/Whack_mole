import streamlit as st
import soundfile as sf

def main():
    st.title("Play a Local WAV file")

    # Specify the path to the local WAV file
    local_file_path = "./preprocessed.wav"
    
    # Read the WAV file
    data, samplerate = sf.read(local_file_path)
    
    # Play the WAV file
    st.audio(local_file_path, format='audio/wav')

if __name__ == "__main__":
    main()