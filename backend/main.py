from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from sqlalchemy import inspect, text

from database.database import engine, Base
from api.endpoints import quests, users

# Initialize database tables
Base.metadata.create_all(bind=engine)


def ensure_last_active_date_column():
    """Ensure the `last_active_date` column exists on the `users` table for SQLite DBs.
    This runs a safe ALTER TABLE to add the column when it's missing (nullable DateTime).
    """
    try:
        inspector = inspect(engine)
        if "users" in inspector.get_table_names():
            cols = [c["name"] for c in inspector.get_columns("users")]
            if "last_active_date" not in cols:
                with engine.connect() as conn:
                    conn.execute(text("ALTER TABLE users ADD COLUMN last_active_date DATETIME"))
                    # commit for some engines; with connection context this is safe
    except Exception:
        # If anything goes wrong here we don't want to crash the app on startup.
        # Migration can be retried manually later.
        pass


# Run lightweight migration / schema fix
ensure_last_active_date_column()

app = FastAPI(
    title="IKO API",
    description="Backend API for IKO Gamified Life Operating System",
    version="1.0.0"
)

# Configure CORS
origins = [
    "http://localhost",
    "http://localhost:8080",
]

# Allow any localhost origin (any port) for development using a regex.
# keep `allow_credentials=False` to avoid combining credentials with wildcard origins.
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_origin_regex=r"^http://localhost(:[0-9]+)?$",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(users.router, prefix="/users", tags=["users"])
app.include_router(quests.router, prefix="/quests", tags=["quests"])

@app.get("/")
def read_root():
    return {"message": "Welcome to IKO API"}

@app.get("/health")
def health_check():
    return {"status": "ok"}

