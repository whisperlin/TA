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
        public int pos_x;
        public int pos_y;
        public int width;
        public int height;
        public bool isOccupied;
    }

    public class Box
    {

        public int width;
        public int height;
        public int volume;
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


        public List<Box> Pack2(int w)
        {
            List<Box> _err = new List<Box>();
            rootNode = new Node { width = w, height = w };
            _boxes.ForEach(x => x.volume = (x.height * x.width));
            _boxes = _boxes.OrderByDescending(x => x.volume).ToList();
            int _time = 2;
            w = w / _time;
            bool[,] b = new bool[w,w];
            for (int i = 0; i < w; i++)
            {
                for (int j = 0; j < w; j++)
                {
                    b[i, j] = false;
                }
            }
            foreach (var box in _boxes)
            {
                int _w = box.width/ _time;
                int _h = box.height/ _time;
                for (int i = 0; i < w  ; i++)
                {
                    for (int j = 0; j < w  ; j++)
                    {
                        //逐像素检查是否能使用.
                        if(i+_w > w || j+_h> w)
                            goto NEXT_PIX;
                        for (int _x = 0; _x < _w  ; _x++)
                        {
                            for (int _y = 0; _y < _h  ; _y++)
                            {
                     
                                if ( b[i+_x, j+_y]  )
                                {
                                    goto NEXT_PIX;
                                }
                            }
                        }
                        //填充说明位置已经使用.
                        for (int _x = 0; _x < _w; _x++)
                        {
                            for (int _y = 0; _y < _h; _y++)
                            {
                                b[i + _x, j + _y] = true;
                                
                            }
                        }
                        Node p = new Node { pos_y = j* _time, pos_x = i* _time, height = box.height, width = box.width };
                        box.position = p;
                        goto NextBox;
                    NEXT_PIX: continue;
                    }
                }

                _err.Add(box);
                 NextBox: continue;
 
            }
            return _err;
        }
        public List<Box>  Pack(int w )
        {
            List<Box> _err = new List<Box>();
            rootNode = new Node { width = w, height = w };
            _boxes.ForEach(x => x.volume = (x.height * x.width));
            _boxes = _boxes.OrderByDescending(x => x.volume).ToList();
            foreach (var box in _boxes)
            { 
                var node = FindNode(rootNode, box.width, box.height);
                if (node != null)
                {
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

        private Node SplitNode(Node node, int boxWidth, int boxLength)
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
