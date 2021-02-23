using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Pack2d
{
    public class Node
    {
        public Node rightNode;
        public Node bottomNode;
        public float pos_x;
        public float pos_y;
        public float width;
        public float height;
        public bool isOccupied;
    }

    public class Box
    {

        public float width;
        public float height;
        public float volume;
        public Node position;

        public object userData;
    }
    public class Packer
    {

       

        private float containerWidth = 48;
        private float containerLength = 93;
        private List<Box> _boxes;
        private Node rootNode;


        public void Add(Box box)
        {
            _boxes.Add(box);
        }
        public Packer()
        {
            _boxes = new List<Box>();
           
             
        }

        private void Display()
        {
            foreach (var box in _boxes)
            {
                var positionx = box.position != null ? box.position.pos_x.ToString() : String.Empty;
                var positionz = box.position != null ? box.position.pos_y.ToString() : String.Empty;
                Console.WriteLine( " Width : " + box.width + " Height : " + box.height + " Pos_x : " + positionx + " Pos_y  : " + positionz);
            }
        }

        public List<Box>  Pack(int w )
        {
            List<Box> _err = new List<Box>();
            rootNode = new Node { width = w, height = w };
            _boxes.ForEach(x => x.volume = (x.height * x.width));
            _boxes = _boxes.OrderByDescending(x => x.volume).ToList();
            bool rs = true;
            foreach (var box in _boxes)
            { 
                var node = FindNode(rootNode, box.width, box.height);
                if (node != null)
                {
                    // Split rectangles
                    box.position = SplitNode(node, box.width, box.height);
                }
                else
                {
                    _err.Add(box);
                }
            }
            return _err;
        }

        private Node FindNode(Node rootNode, float boxWidth, float boxLength)
        {
            if (rootNode.isOccupied) 
            {
                var nextNode = FindNode(rootNode.bottomNode, boxWidth, boxLength);

                if (nextNode == null)
                {
                    nextNode = FindNode(rootNode.rightNode, boxWidth, boxLength);
                }

                return nextNode;
            }
            else if (boxWidth <= rootNode.width && boxLength <= rootNode.height)
            {
                return rootNode;
            }
            else 
            {
                return null;
            }
        }

        private Node SplitNode(Node node, float boxWidth, float boxLength)
        {
            node.isOccupied = true;
            node.bottomNode = new Node { pos_y = node.pos_y, pos_x = node.pos_x + boxWidth, height = node.height, width = node.width - boxWidth };
            node.rightNode = new Node { pos_y = node.pos_y + boxLength, pos_x = node.pos_x, height = node.height - boxLength, width = boxWidth };
            return node;
        }

        public List<Box>  GetBoxs()
        {
            return _boxes;
        }
    }
}
