import streamlit as st
from Constants import Constants

st.sidebar.image(Constants.LOGO_IMAGE, use_column_width=True)
st.image(Constants.LOGO_IMAGE, use_column_width=True)

st.write(Constants.HELLO_MESSAGE)
