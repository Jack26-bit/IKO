"""
Compatibility shim: lets the platform supervisor (`uvicorn server:app`) boot the
existing FastAPI application defined in `main.py` without forcing a rename.
"""

from main import app  # noqa: F401  (re-exported)
