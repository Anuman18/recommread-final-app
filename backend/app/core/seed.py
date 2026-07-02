from sqlalchemy.orm import Session
from ..models.career import Career, Topic, Resource, Project, ProjectMilestone
from ..models.coding import CodingQuestion
from ..models.interview import InterviewType, InterviewQuestion
from ..models.user import Profile

def seed_database(db: Session):
    # Check if already seeded
    if db.query(Career).first() is not None:
        return

    print("Seeding database with mock AI Career & Learning OS data...")

    # 1. Careers
    careers = [
        Career(slug="ai_engineer", name="AI Engineer", description="Build state-of-the-art neural architectures, fine-tune LLMs, and optimize real-time inference scales."),
        Career(slug="data_scientist", name="Data Scientist", description="Analyze complex statistical models, build custom predictors, and translate dataset footprints into business revenue."),
        Career(slug="ux_designer", name="UI/UX Designer", description="Formulate user journeys, audit interface layouts, and coordinate pixel-perfect developer handoffs."),
    ]
    for c in careers:
        db.add(c)
    db.commit()

    # 2. Topics
    topics = [
        # AI Engineer
        Topic(id="ai_python", career_slug="ai_engineer", name="Python Algorithms", total_questions=6, difficulty_distribution={"Easy": 3, "Medium": 2, "Hard": 1}),
        Topic(id="ai_linear", career_slug="ai_engineer", name="Linear Algebra", total_questions=4, difficulty_distribution={"Easy": 2, "Medium": 2, "Hard": 0}),
        Topic(id="ai_pytorch", career_slug="ai_engineer", name="PyTorch Layers", total_questions=5, difficulty_distribution={"Easy": 1, "Medium": 3, "Hard": 1}),
        Topic(id="ai_llm", career_slug="ai_engineer", name="LLM Prompt Engineering", total_questions=5, difficulty_distribution={"Easy": 3, "Medium": 2, "Hard": 0}),
        Topic(id="ai_nn", career_slug="ai_engineer", name="Neural Networks", total_questions=4, difficulty_distribution={"Easy": 1, "Medium": 2, "Hard": 1}),

        # Data Scientist
        Topic(id="ds_python", career_slug="data_scientist", name="Python Basics", total_questions=6, difficulty_distribution={"Easy": 4, "Medium": 2, "Hard": 0}),
        Topic(id="ds_numpy", career_slug="data_scientist", name="NumPy Arrays", total_questions=4, difficulty_distribution={"Easy": 2, "Medium": 2, "Hard": 0}),
        Topic(id="ds_pandas", career_slug="data_scientist", name="Pandas DataFrames", total_questions=5, difficulty_distribution={"Easy": 2, "Medium": 2, "Hard": 1}),
        Topic(id="ds_sql", career_slug="data_scientist", name="SQL Queries", total_questions=6, difficulty_distribution={"Easy": 3, "Medium": 2, "Hard": 1}),
        Topic(id="ds_ml", career_slug="data_scientist", name="Machine Learning", total_questions=5, difficulty_distribution={"Easy": 1, "Medium": 3, "Hard": 1}),
        Topic(id="ds_stats", career_slug="data_scientist", name="Statistics & Math", total_questions=4, difficulty_distribution={"Easy": 2, "Medium": 2, "Hard": 0}),
        Topic(id="ds_viz", career_slug="data_scientist", name="Data Visualization", total_questions=3, difficulty_distribution={"Easy": 2, "Medium": 1, "Hard": 0}),

        # UI/UX Designer
        Topic(id="ux_figma", career_slug="ux_designer", name="Figma Dev Handoff", total_questions=5, difficulty_distribution={"Easy": 3, "Medium": 2, "Hard": 0}),
        Topic(id="ux_systems", career_slug="ux_designer", name="Design Systems", total_questions=4, difficulty_distribution={"Easy": 2, "Medium": 2, "Hard": 0}),
        Topic(id="ux_html", career_slug="ux_designer", name="HTML Structure", total_questions=6, difficulty_distribution={"Easy": 4, "Medium": 2, "Hard": 0}),
        Topic(id="ux_css", career_slug="ux_designer", name="CSS Flex & Grid", total_questions=6, difficulty_distribution={"Easy": 3, "Medium": 2, "Hard": 1}),
    ]
    for t in topics:
        db.add(t)
    db.commit()

    # 3. CodingQuestions
    questions = [
        CodingQuestion(
            id="q1",
            topic_id="ds_python",
            title="Reverse elements of a List",
            difficulty="Easy",
            companies=["Google", "Amazon", "Meta"],
            time_min=10,
            xp_reward=100,
            coins_reward=10,
            hints=["You can use slice notation list[::-1] in Python.", "Alternatively, use list.reverse() in-place."],
            problem_statement="Given an array of integers, return a new array with elements in reversed order.",
            examples=[{"input": "[1, 2, 3, 4]", "output": "[4, 3, 2, 1]"}, {"input": "[7, 8]", "output": "[8, 7]"}],
            constraints=["List size ranges from 0 to 10^5.", "Values are standard signed integers."],
            expected_output="[4, 3, 2, 1]",
            editorial="Reversing a list in Python is commonly performed via slicing list[::-1] which runs in O(N) time complexity and copies the pointer values.",
            doc_url="https://docs.python.org/3/tutorial/datastructures.html",
            video_url="https://youtube.com"
        ),
        CodingQuestion(
            id="q2",
            topic_id="ds_python",
            title="Find Missing Value in Range",
            difficulty="Easy",
            companies=["Meta", "Microsoft"],
            time_min=15,
            xp_reward=120,
            coins_reward=12,
            hints=["Calculate the sum of all elements from 0 to N.", "Substract the sum of elements present in list."],
            problem_statement="Given a list containing N distinct numbers taken from 0, 1, 2, ..., N, find the one that is missing from the list.",
            examples=[{"input": "[3, 0, 1]", "output": "2", "explanation": "N=3. The range is 0 to 3. 2 is missing."}],
            constraints=["N == nums.length", "1 <= N <= 10^4", "All numbers in list are unique."],
            expected_output="2",
            editorial="Using Gauss summation formula: ExpectedSum = N * (N + 1) / 2. Subtracting the actual sum of the array yields the missing item in O(N) time and O(1) space.",
            doc_url="https://docs.python.org",
            video_url="https://youtube.com"
        ),
        CodingQuestion(
            id="q3",
            topic_id="ds_numpy",
            title="Matrix Dot Product Multiplication",
            difficulty="Medium",
            companies=["Tesla", "Nvidia", "OpenAI"],
            time_min=20,
            xp_reward=200,
            coins_reward=20,
            hints=["Ensure inner dimensions match: shape A is (M, K) and shape B is (K, N).", "Use np.dot(A, B) or the @ operator."],
            problem_statement="Write a function executing dot-product multiplication of two matrices represented as numpy array inputs.",
            examples=[{"input": "A = [[1, 2], [3, 4]], B = [[5], [6]]", "output": "[[17], [39]]"}],
            constraints=["Input arrays are numeric only.", "Matrix dimensions match dot product requirements."],
            expected_output="[[17], [39]]",
            editorial="Matrix multiplication is computed by summing the product of row elements of A with column elements of B. NumPy uses BLAS under the hood for O(N^2.8) optimized multipliers.",
            doc_url="https://numpy.org/doc/stable/reference/generated/numpy.dot.html",
            video_url="https://youtube.com"
        ),
        CodingQuestion(
            id="q4",
            topic_id="ds_pandas",
            title="Filter Missing DataFrame Ages",
            difficulty="Easy",
            companies=["Netflix", "Uber"],
            time_min=12,
            xp_reward=110,
            coins_reward=10,
            hints=["Check out df.dropna() or df[df['age'].notna()].", "In pandas, missing items are parsed as NaN."],
            problem_statement="Filter rows in a user DataFrame where the column 'age' is missing.",
            examples=[{"input": "df with ages [25, NaN, 30]", "output": "df with ages [25, 30]"}],
            constraints=["DataFrame rows <= 10^6."],
            expected_output="[25, 30]",
            editorial="Filtering rows is done via boolean masking: df[df['age'].notna()] which keeps indices matching true boolean rows.",
            doc_url="https://pandas.pydata.org",
            video_url="https://youtube.com"
        ),
        CodingQuestion(
            id="q5",
            topic_id="ds_sql",
            title="Find Second Highest Salary",
            difficulty="Medium",
            companies=["Google", "Meta", "Amazon"],
            time_min=18,
            xp_reward=180,
            coins_reward=18,
            hints=["Sort by salary descending and offset by 1.", "Use DISTINCT to handle duplicates.", "Ensure you return NULL if no second highest exists."],
            problem_statement="Write an SQL query to retrieve the second highest distinct salary from the Employee table. Return NULL if it doesn't exist.",
            examples=[{"input": "Employee: [1: 100, 2: 200, 3: 300]", "output": "200"}],
            constraints=["Database columns indexed properly."],
            expected_output="200",
            editorial="Select max(salary) from Employee where salary < (Select max(salary) from Employee) is an index-safe approach.",
            doc_url="https://dev.mysql.com/doc",
            video_url="https://youtube.com"
        )
    ]
    for q in questions:
        db.add(q)
    db.commit()

    # 4. Resources
    resources = [
        # AI Engineer
        Resource(id=1, career_slug="ai_engineer", title="Official PyTorch Documentation", category="Documentation", url="https://pytorch.org/docs", description="Official API documentation detailing tensor arithmetic and network layer classes.", why_recommended="Deep learning foundations require detailed reference checkouts.", skills=["PyTorch", "Python"]),
        Resource(id=2, career_slug="ai_engineer", title="Andrej Karpathy: Zero to Hero", category="YouTube", url="https://youtube.com", description="Complete masterclass on building neural nets, backpropagation mechanics, and GPT models from scratch.", why_recommended="Karpathy provides the highest-quality fundamentals explanation.", skills=["Transformers", "Neural Networks"]),
        Resource(id=3, career_slug="ai_engineer", title="Deep Learning Specialization (Coursera)", category="Courses", url="https://coursera.org", description="Deep Learning course sequence covering ConvNets, RNNs, optimization, and training strategy structures.", why_recommended="Highly comprehensive overview for structured algorithm training.", skills=["Neural Networks", "Linear Algebra"]),

        # Data Scientist
        Resource(id=4, career_slug="data_scientist", title="Pandas User Guide", category="Documentation", url="https://pandas.pydata.org/docs", description="Official Pandas manual detailing index alignment, sorting, merges, and indexing models.", why_recommended="Essential library reference for core data cleansing.", skills=["Pandas", "Python"]),
        Resource(id=5, career_slug="data_scientist", title="StatQuest: Machine Learning Basics", category="YouTube", url="https://youtube.com", description="Intelligent breakdown of regression models, Random Forests, bagging, boosting, and variance control.", why_recommended="Visual descriptions make statistics math intuitive.", skills=["Statistics", "ML Theory"]),

        # UI/UX Designer
        Resource(id=6, career_slug="ux_designer", title="Figma Help Center: Dev Mode", category="Documentation", url="https://figma.com", description="Official guides explaining dev handoff modes, inspect panels, styles translations, and code attributes.", why_recommended="Key interface handoff documentation for designers.", skills=["Figma", "Handoff"]),
    ]
    for r in resources:
        db.add(r)
    db.commit()

    # 5. Projects
    projects = [
        # AI Engineer
        Project(
            id="ai_proj_1",
            career_slug="ai_engineer",
            name="Multimodal RAG Knowledge Assistant",
            difficulty="Hard",
            duration="3 weeks",
            skills=["Python", "PyTorch", "LLMs", "Vector DBs"],
            xp_reward=600,
            coins_reward=60,
            portfolio_value="Ultra High",
            problem_statement="Legacy enterprise search indices cannot handle multimodal data (images, code files, layouts) concurrently, causing severe information discovery gaps.",
            what_you_build="We will build an asynchronous multi-pipeline indexing crawler using ColPali / CLIP embeddings and a local Vector storage index with dynamic Citations sources.",
            tech_stack=["FastAPI", "PyTorch", "Qdrant", "HuggingFace Transformers"],
            prerequisites=["Understanding of cosine similarity math", "GPU memory quantization rules"],
            dataset_url="https://github.com",
            image_url="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe"
        ),
        # Data Scientist
        Project(
            id="ds_proj_1",
            career_slug="data_scientist",
            name="Dynamic Churn Prediction Engine",
            difficulty="Medium",
            duration="2 weeks",
            skills=["Python", "Pandas", "Scikit-Learn", "SQL"],
            xp_reward=500,
            coins_reward=50,
            portfolio_value="High",
            problem_statement="Subscriber drop-off causes significant monthly losses. Predicting churn beforehand allows targeted promotional outreach.",
            what_you_build="We will develop an end-to-end analytical prediction pipeline using XGBoost, handling class imbalance via SMOTE and deploying a query dashboard.",
            tech_stack=["Python", "Scikit-Learn", "Streamlit", "PostgreSQL"],
            prerequisites=["Understanding of precision-recall metrics", "Handling missing database ages"],
            dataset_url="https://github.com",
            image_url="https://images.unsplash.com/photo-1551288049-bebda4e38f71"
        )
    ]
    for p in projects:
        db.add(p)
    db.commit()

    # 6. ProjectMilestones
    milestones = [
        ProjectMilestone(id="ai_proj_1_ms1", project_id="ai_proj_1", text="Process PDF layouts and parse images using OCR pipelines.", xp_reward=100, coins_reward=10),
        ProjectMilestone(id="ai_proj_1_ms2", project_id="ai_proj_1", text="Encode embeddings and save coordinates in Qdrant.", xp_reward=150, coins_reward=15),
        ProjectMilestone(id="ai_proj_1_ms3", project_id="ai_proj_1", text="Formulate LLM prompts and serve query responses.", xp_reward=200, coins_reward=20),

        ProjectMilestone(id="ds_proj_1_ms1", project_id="ds_proj_1", text="Load transactional records and resolve missing values.", xp_reward=100, coins_reward=10),
        ProjectMilestone(id="ds_proj_1_ms2", project_id="ds_proj_1", text="Train XGBoost and balance weights using SMOTE.", xp_reward=150, coins_reward=15),
        ProjectMilestone(id="ds_proj_1_ms3", project_id="ds_proj_1", text="Deploy the Streamlit dashboard on a local server.", xp_reward=200, coins_reward=20)
    ]
    for m in milestones:
        db.add(m)
    db.commit()

    # 7. InterviewTypes
    types = [
        InterviewType(id="int_tech", name="Technical Interview", description="Deep-dive into language constraints, model scaling, and optimization.", icon="💻", question_count=3, duration_min=15),
        InterviewType(id="int_beh", name="Behavioral Interview", description="Assess communication structure, developer conflict resolution, and leadership.", icon="🤝", question_count=3, duration_min=12),
        InterviewType(id="int_hr", name="HR Interview", description="Standard salary review, corporate fitment checklists, and background logs.", icon="🏢", question_count=2, duration_min=10),
        InterviewType(id="int_sys", name="System Design", description="Design rate limiters, scale caches, and partition vector databases.", icon="📐", question_count=3, duration_min=20),
        InterviewType(id="int_case", name="Case Study", description="Analyze business conversion drops and audit interface user flows.", icon="📊", question_count=2, duration_min=18),
        InterviewType(id="int_rapid", name="Rapid Fire", description="Quick-response technical trivia under strict timer constraints.", icon="⚡", question_count=5, duration_min=5),
        InterviewType(id="int_code", name="Coding Interview", description="Live coding problem analysis, complexity audits, and test execution.", icon="🧩", question_count=2, duration_min=15),
        InterviewType(id="int_viva", name="Mock Viva", description="Verbal theory defense covering model weights and activation math.", icon="🎤", question_count=3, duration_min=12),
    ]
    for t in types:
        db.add(t)
    db.commit()

    # 8. InterviewQuestions
    int_questions = [
        # AI Engineer
        InterviewQuestion(id="q_ai_1", career_slug="ai_engineer", type_id="int_tech", text="Explain the self-attention matrix query, key, and value multipliers. Why is scale scaling required?", difficulty="Hard", topic="Transformers"),
        InterviewQuestion(id="q_ai_2", career_slug="ai_engineer", type_id="int_tech", text="What is parameter-efficient fine-tuning (LoRA), and how does it optimize training GPU memory bounds?", difficulty="Medium", topic="LLM Fine-Tuning"),
        InterviewQuestion(id="q_ai_3", career_slug="ai_engineer", type_id="int_sys", text="How would you architect a real-time multimodal RAG assistant handling both vector indexing and document structure citations?", difficulty="Hard", topic="System Design"),

        # Data Scientist
        InterviewQuestion(id="q_ds_1", career_slug="data_scientist", type_id="int_tech", text="Explain the bias-variance tradeoff in machine learning, and how regularization helps.", difficulty="Medium", topic="ML Theory"),
        InterviewQuestion(id="q_ds_2", career_slug="data_scientist", type_id="int_case", text="What is customer churn, and how would you evaluate model performance if classes are highly imbalanced?", difficulty="Hard", topic="Metrics"),
        InterviewQuestion(id="q_ds_3", career_slug="data_scientist", type_id="int_tech", text="How do you check for and handle multicollinearity in a multiple linear regression model?", difficulty="Medium", topic="Statistics"),

        # UI/UX Designer
        InterviewQuestion(id="q_ux_1", career_slug="ux_designer", type_id="int_tech", text="How do you conduct user research for a fintech app, and how does it translate to high-fidelity wireframes?", difficulty="Medium", topic="UX Research"),
        InterviewQuestion(id="q_ux_2", career_slug="ux_designer", type_id="int_case", text="Explain Nielsen's Usability Heuristics and how you apply them when auditing cart checkout pages.", difficulty="Easy", topic="Heuristics"),
        InterviewQuestion(id="q_ux_3", career_slug="ux_designer", type_id="int_beh", text="How do you resolve feedback conflicts when engineers state that a custom layout micro-interaction is too expensive to code?", difficulty="Hard", topic="Handoff"),
    ]
    for iq in int_questions:
        db.add(iq)
    db.commit()

    # 9. Seed some mock users for leaderboards
    mock_users = [
        {"name": "Siddharth M.", "xp": 3450, "avatar": "🦊", "career": "ai_engineer"},
        {"name": "Priyanjali S.", "xp": 2900, "avatar": "🦁", "career": "data_scientist"},
        {"name": "Rohan Gupta", "xp": 2100, "avatar": "🐯", "career": "ai_engineer"},
        {"name": "Amit Kumar", "xp": 1200, "avatar": "🐻", "career": "ux_designer"},
        {"name": "Nisha R.", "xp": 950, "avatar": "🐼", "career": "ux_designer"},
    ]
    # We will query profiles inside route or load them, but we can seed Profile details here.
    # To keep user_id constraints clean, we won't seed actual foreign key users for mock entries;
    # instead, we can just return these static mock leaderboard rows in our leaderboard endpoint!
    # That is extremely clean and doesn't pollute the user tables.

    print("Database seeded successfully.")
