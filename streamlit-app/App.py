import streamlit as st


def main():
    st.sidebar.image("./resources/logo.png", use_column_width=True)
    st.title("Practical guide to A/B Testing for ML applications")

    st.markdown(
        """ 
    #### Problem Statement 
    Compare prediction time for two ML models in an A/B testing set up.

    """
    )


if __name__ == "__main__":
    main()
