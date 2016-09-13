
using System;

namespace Indico.Models
{
    public class GetPatternDevelopmentsModel
    {

        public int ID { get; set; }
        public bool Spec { get; set; }
        public bool LectraPattern { get; set; }
        public bool WhiteSample { get; set; }
        public bool LogoPositioning { get; set; }
        public bool Photo { get; set; }
        public bool Fake3DVis { get; set; }
        public bool NestedWireframe { get; set; }
        public bool BySizeWireframe { get; set; }
        public bool PreProd { get; set; }
        public bool SpecChart { get; set; }
        public bool FinalTemplate { get; set; }
        public bool TemplateApproved { get; set; }
        public string Remarks { get; set; }
        public string Description { get; set; }
        public string PatternNumber { get; set; }
        public string LastModifier { get; set; }
        public DateTime LastModified { get; set; }
        public string Creator { get; set; }
        public DateTime Created { get; set; }
    }
}