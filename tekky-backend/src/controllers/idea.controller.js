import prisma from "../config/db.js";

/* ------------------------------------------------------------------
   GET /api/ideas
-------------------------------------------------------------------*/
export async function getIdeas(req, res) {
  try {
    const ideas = await prisma.idea.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        owner: {
          select: { id: true, name: true, email: true }
        }
      }
    });

    res.json(ideas);
  } catch (err) {
    console.error("Error fetching ideas:", err);
    res.status(500).json({ error: "Failed to fetch ideas" });
  }
}

/* ------------------------------------------------------------------
   GET /api/ideas/:id
-------------------------------------------------------------------*/
export async function getIdeaById(req, res) {
  try {
    const idea = await prisma.idea.findUnique({
      where: { id: req.params.id },
      include: {
        owner: {
          select: { id: true, name: true, email: true }
        },
        interests: {
          include: {
            user: {
              select: { id: true, name: true }
            }
          }
        },
        collaborators: {
          include: {
            user: {
              select: { id: true, name: true }
            }
          }
        }
      }
    });

    if (!idea) return res.status(404).json({ error: "Idea not found" });

    res.json(idea);
  } catch (err) {
    console.error("Error fetching idea:", err);
    res.status(500).json({ error: "Failed to fetch idea" });
  }
}

/* ------------------------------------------------------------------
   POST /api/ideas  (auth required)
-------------------------------------------------------------------*/
export async function createIdea(req, res) {
  try {
    const { title, description, techStacks, lookingFor } = req.body;

    if (!title || !description) {
      return res.status(400).json({ error: "Missing fields" });
    }

    const idea = await prisma.idea.create({
      data: {
        title,
        description,
        techStacks: techStacks ?? [],
        lookingFor: lookingFor ?? [],
        ownerId: req.user.userId,
      }
    });

    res.status(201).json(idea);
  } catch (err) {
    console.error("Error creating idea:", err);
    res.status(500).json({ error: "Failed to create idea" });
  }
}

/* ------------------------------------------------------------------
   POST /api/ideas/:id/interest  (auth required)
-------------------------------------------------------------------*/
export async function sendInterest(req, res) {
  try {
    const ideaId = req.params.id;
    const userId = req.user.userId;

    const idea = await prisma.idea.findUnique({
      where: { id: ideaId }
    });

    if (!idea) {
      return res.status(404).json({ error: "Idea not found" });
    }

    if (idea.ownerId === userId) {
      return res.status(400).json({ error: "You cannot apply to your own idea" });
    }

    // Check duplicate interest
    const existing = await prisma.interest.findFirst({
      where: {
        ideaId,
        userId
      }
    });

    if (existing) {
      return res.status(400).json({ error: "Interest already sent" });
    }

    const interest = await prisma.interest.create({
      data: {
        ideaId,
        userId
      }
    });

    res.status(201).json(interest);
  } catch (err) {
    console.error("Error sending interest:", err);
    res.status(500).json({ error: "Failed to send interest" });
  }
}
