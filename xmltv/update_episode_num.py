import argparse
import xml
from xml.dom.minidom import parse, parseString


def add_episode_num(
    system: str,
    content: str,
    programme: xml.dom.minidom.Element,
    document: xml.dom.minidom.Document,
):
    """Add an episode-num tag to a programme element

    Args:
        system (str): The system of the episode number. Usually 'onscreen' or 'xmltv_ns'
        content (str): The content of the episode number
        programme (xml.dom.minidom.Element): The programme to add the episode number to
        document (xml.dom.minidom.Document): The document that the programme is in
    """
    episode_num = document.createElement("episode-num")
    episode_num.setAttribute("system", system)
    episode_num_text = document.createTextNode(content)
    episode_num.appendChild(episode_num_text)
    programme.appendChild(episode_num)


def has_episode_num(programme: xml.dom.minidom.Element):
    """Check if a programme has an episode number

    Args:
        programme (xml.dom.minidom.Element): The programme to check

    Returns:
        bool: True if the programme has an episode number, False otherwise
    """
    episode_num = programme.getElementsByTagName("episode-num")
    if len(episode_num) > 0:
        return True
    return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--guide", help="Path to XMLTV Guide file", required=True)
    parser.add_argument(
        "--save-to",
        help="Path to updated XMLTV Guide file that ill be created",
        required=True,
    )

    args = parser.parse_args()

    with open(args.save_to, "w") as f:
        # Parse XML from a filename
        document = parse(args.guide)

        # We want to add an episode-num tag to each programme
        programme = document.getElementsByTagName("programme")
        for p in programme:
            # Check if it already has an episode number
            if has_episode_num(p):
                # If it does, skip it
                continue
            # The season is the first 4 digits of the start time (YYYY) and the episode is the next 4 (MMDD) separated by a dot
            onscreen = p.getAttribute("start")[:4] + "." + p.getAttribute("start")[4:8]
            add_episode_num("onscreen", onscreen, p, document)
        # Write the updated XML to a file
        document.writexml(f)


if __name__ == "__main__":
    main()
